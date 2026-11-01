import Foundation
import GraniteAgents
import XCTest
@testable import LoomAgent

/// The package as an app finds it: by its record, with the schema a model is shown and the guide a host prompts with.
final class LoomAgentTests: XCTestCase {
    func testTheRecordIsFoundWithNothingListed() throws {
        let loom = try XCTUnwrap(GraniteRoster.discovered().package("loom"), "the record is in this test binary")
        XCTAssertEqual(loom.module, "LoomAgent")
        XCTAssertEqual(loom.summary, LoomAgent.summary)
    }

    func testTheSchemaIsWhatAModelIsShown() {
        let loom = AnyAgentPackage(LoomAgent.self)
        XCTAssertEqual(loom.schema, .object([
            .init(name: "into", schema: .string, required: false),
            .init(name: "mappings", schema: .array(.string), required: false),
            .init(name: "style", schema: .choice(["loom", "social", "reader"]), required: false),
            .init(name: "colors", schema: .choice(["code", "assets"]), required: false),
            .init(name: "features", schema: .array(.choice(["vote", "save", "share", "reply", "report", "block", "nsfwShield",
                                                             "markdown", "linkPreview", "media", "swipeActions", "editing"])), required: false),
            .init(name: "screens", schema: .array(.choice(["feed", "post", "thread", "compose", "reply", "profile", "community",
                                                            "search", "instances", "filter", "share"])), required: false),
            .init(name: "prefix", schema: .string, required: false),
            .init(name: "imports", schema: .array(.string), required: false),
            .init(name: "directory", schema: .string, required: false),
        ]))
        XCTAssertTrue(loom.takesDirectory)
        XCTAssertEqual(Set(loom.fields.keys), ["into", "mappings", "style", "colors", "features", "screens", "prefix", "imports"],
                       "a note beside every field the model sees")
        XCTAssertEqual(loom.lanes, 2)
    }

    func testTheGuideTeachesTheLineAndOneCallPerMode() {
        let guide = AnyAgentPackage(LoomAgent.self).guide
        for word in ["mappings", "post (", "comment (", "user (", "community (", "instance (", "value", "id=", "imports",
                     "style", "prefix", "features", "screens", "AppSocial", "SocialActions", "FeedView", "#Preview"] {
            XCTAssertTrue(guide.contains(word), "the guide says \(word)")
        }
        // Every word a role maps is in the guide, so the model never has to guess one.
        for role in SocialRole.allCases {
            for property in role.properties { XCTAssertTrue(guide.contains(property.key), "the guide names \(role).\(property.key)") }
        }
        // One example call a mode: the whole kit, a smaller look-specific kit, and a later call that adds screens.
        let examples = guide.components(separatedBy: "{\"").count - 1
        XCTAssertEqual(examples, 3, "three example calls")
        XCTAssertFalse(guide.contains("Federated"), "no Loom type names to copy")
    }

    /// The call as a host makes it: JSON in, the host's folder filled, JSON out naming the files.
    func testACallThroughTheRosterWritesTheFilesItNames() async throws {
        let folder = try Fixture.folder()
        let input = try JSONSerialization.data(withJSONObject: ["mappings": Fixture.cooking, "directory": folder.path])
        let answer = try await AnyAgentPackage(LoomAgent.self).perform(input, host: AgentHost(directory: folder.path, ask: "the social screens"))
        let result = try JSONDecoder().decode(LoomResult.self, from: answer)
        let social = folder.appendingPathComponent("Shared/Views/Social").path
        XCTAssertEqual(result.path, result.paths.first)
        for path in result.paths {
            XCTAssertTrue(path.hasPrefix(social + "/"), path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: path), path)
        }
        let names = Set(result.paths.map { URL(fileURLWithPath: $0).lastPathComponent })
        for name in ["SocialProtocols.swift", "SocialStyle.swift", "SocialActions.swift", "SocialPreviews.swift", "PostCardView.swift",
                     "CommentThreadView.swift", "FeedView.swift", "ComposeView.swift", "SearchView.swift", "Dish+Post.swift",
                     "Note+Comment.swift", "Cook+User.swift", "Club+Community.swift", "AppSocial.swift"] {
            XCTAssertTrue(names.contains(name), name)
        }
        XCTAssertEqual(result.schema, "AppSocial")
        XCTAssertEqual(result.conformances, ["Dish: post", "Note: comment", "Cook: user", "Club: community"])
        XCTAssertTrue(result.views.contains("PostCardView"))
        XCTAssertEqual(result.notes, ["AppSocial uses SocialNoInstance for the roles no line maps."])
    }

    /// A host over the wire may name its folder only in `AgentHost`: every file lands there all the same.
    func testTheHostsFolderIsUsedWhenTheCallNamesNone() async throws {
        let folder = try Fixture.folder()
        let input = try JSONSerialization.data(withJSONObject: ["mappings": Fixture.cooking, "screens": ["thread"]])
        let answer = try await AnyAgentPackage(LoomAgent.self).perform(input, host: AgentHost(directory: folder.path))
        let result = try JSONDecoder().decode(LoomResult.self, from: answer)
        XCTAssertFalse(result.paths.isEmpty)
        for path in result.paths {
            XCTAssertTrue(path.hasPrefix(folder.path + "/"), "\(path) is not under the host's folder")
            XCTAssertTrue(FileManager.default.fileExists(atPath: path), path)
        }
    }
}
