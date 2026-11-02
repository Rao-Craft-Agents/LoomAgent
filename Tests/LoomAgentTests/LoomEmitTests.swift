import Foundation
import XCTest
@testable import LoomAgent

/// What the files say: the conformances the lines make, the parts the screens and features choose, the prefix, and
/// nothing written when the call is refused.
final class LoomEmitTests: XCTestCase {
    private func write(_ input: LoomAgent.Input) throws -> (LoomResult, URL) {
        let folder = try Fixture.folder()
        var input = input
        input.directory = folder.path
        return (try LoomAgent.write(input, note: { _ in }, yield: { _ in }), folder)
    }

    private func names(_ result: LoomResult) -> Set<String> {
        Set(result.paths.map { URL(fileURLWithPath: $0).lastPathComponent })
    }

    func testAConformanceReadsPathsThroughSocialValueAndBindsValueOnlyWhenNamed() throws {
        let (result, _) = try write(.init(mappings: [#"post: Dish id=key title=value.name ?? "Untitled" author=cook.name created=sharedAt"#]))
        let dish = try Fixture.text(result.paths, "Dish+Post.swift")
        XCTAssertTrue(dish.contains("extension Dish: PostRepresentable {"))
        XCTAssertTrue(dish.contains("public var id: String { SocialValue.id(self.key) }"), "a public type's id must be public")
        XCTAssertTrue(dish.contains("var socialAuthorName: String { SocialValue.text(self.cook.name) }"))
        XCTAssertTrue(dish.contains("var socialCreated: Date? { SocialValue.date(self.sharedAt) }"))
        XCTAssertTrue(dish.contains("        let value = self\n        return SocialValue.text(value.name ?? \"Untitled\")"))
        XCTAssertFalse(dish.contains("socialBody"), "an unmapped property keeps the protocol's default")
        let schema = try Fixture.text(result.paths, "AppSocial.swift")
        XCTAssertTrue(schema.contains("enum AppSocial: SocialSchema {"))
        XCTAssertTrue(schema.contains("typealias Post = Dish"))
        XCTAssertTrue(schema.contains("typealias Community = SocialNoCommunity"))
    }

    func testAnIdTheTypeHasIsNotRedeclaredAndImportsAreWritten() throws {
        let (result, _) = try write(.init(mappings: ["post: Kit.Dish id=id title=name"], imports: ["Kit"]))
        let dish = try Fixture.text(result.paths, "KitDish+Post.swift")
        XCTAssertFalse(dish.contains("var id"))
        XCTAssertTrue(dish.hasPrefix("import Foundation\nimport Kit\n"))
        XCTAssertTrue(try Fixture.text(result.paths, "AppSocial.swift").contains("import Kit"))
    }

    /// A status is a post and a reply: what both protocols ask for is written once, as a line maps it or as its
    /// default, since Swift will not choose between two protocols' defaults for one type.
    func testOneTypeInTwoRolesWritesSharedMembersOnce() throws {
        let (result, _) = try write(.init(mappings: [
            "post: Status body=content author=account.name score=likes comments=replies",
            "comment: Status body=content author=account.name score=likes replies=replies parent=inReplyTo",
        ]))
        let post = try Fixture.text(result.paths, "Status+Post.swift")
        let comment = try Fixture.text(result.paths, "Status+Comment.swift")
        XCTAssertEqual(post.components(separatedBy: "var socialAuthorName").count, 2)
        XCTAssertFalse(comment.contains("socialAuthorName"))
        XCTAssertTrue(post.contains("var socialAuthorHandle: String? { nil }"), "a shared default is written out")
        XCTAssertTrue(post.contains("var socialBody: String? { SocialValue.optionalText(self.content) }"))
        XCTAssertTrue(comment.contains("var socialText: String { SocialValue.text(self.content) }"))
        XCTAssertTrue(comment.contains("var socialParentID: String? { SocialValue.optionalText(self.inReplyTo) }"))
        let schema = try Fixture.text(result.paths, "AppSocial.swift")
        XCTAssertTrue(schema.contains("typealias Post = Status") && schema.contains("typealias Comment = Status"))
    }

    func testRolesThatDisagreeAreRefusedAndNothingIsWritten() throws {
        let folder = try Fixture.folder()
        let input = LoomAgent.Input(mappings: [
            "post: Status author=account.name", "comment: Status author=account.displayName",
            "user: Status name=handle", "post: Other title=name", "group: Nope name=x",
        ], prefix: "kit", imports: ["Not A Module"], directory: folder.path)
        XCTAssertThrowsError(try LoomAgent.write(input, note: { _ in }, yield: { _ in })) { error in
            let text = "\(error)"
            for reason in ["problems with the call", "`Status` maps `author` one way", "post is mapped twice", "`kit` is not a prefix",
                           "`Not A Module` is not a module name"] {
                XCTAssertTrue(text.contains(reason), "\(reason) in \(text)")
            }
        }
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), [], "nothing is written")
    }

    func testAnEarlierCallsRolesStayInTheSchema() throws {
        let (_, folder) = try write(.init(mappings: ["post: Dish title=name"], screens: []))
        var input = LoomAgent.Input(mappings: ["user: Cook name=handle"], screens: [])
        input.directory = folder.path
        let second = try LoomAgent.write(input, note: { _ in }, yield: { _ in })
        let schema = try Fixture.text(second.paths, "AppSocial.swift")
        XCTAssertTrue(schema.contains("typealias Post = Dish"), "read off Dish+Post.swift: \(schema)")
        XCTAssertTrue(schema.contains("typealias User = Cook"))
    }

    /// A later call adds to the kit in its folder: the shared files keep what the earlier views use, and the folder's
    /// prefix and look carry over.
    func testALaterCallAddsToTheKitInTheFolder() throws {
        let (_, folder) = try write(.init(style: .social, features: [.vote], screens: [.compose], prefix: "Kit"))
        var later = LoomAgent.Input(features: [.save], screens: [.search])
        later.directory = folder.path
        let second = try LoomAgent.write(later, note: { _ in }, yield: { _ in })
        let actions = try Fixture.text(second.paths, "SocialActions.swift")
        for member in ["var vote:", "var save:", "var submit:", "var search:"] {
            XCTAssertTrue(actions.contains(member), "\(member): the earlier compose view and the new search both need it")
        }
        XCTAssertTrue(names(second).isSuperset(of: ["KitComposeView.swift", "KitSearchView.swift"]), "the prefix carries over")
        XCTAssertTrue(try Fixture.text(second.paths, "SocialStyle.swift").contains("defaultValue: SocialStyle = .social"),
                      "the look carries over")
        XCTAssertTrue(second.notes.contains { $0.contains("already held") })

        var other = LoomAgent.Input(screens: [.feed], prefix: "Feed")
        other.directory = folder.path
        XCTAssertThrowsError(try LoomAgent.write(other, note: { _ in }, yield: { _ in })) { error in
            XCTAssertTrue("\(error)".contains("already holds the views prefixed `Kit`"), "\(error)")
        }
    }

    func testScreensChooseTheirPartsAndFeaturesTheirControls() throws {
        let (thread, _) = try write(.init(features: [.vote, .reply, .swipeActions], screens: [.thread]))
        XCTAssertEqual(names(thread).filter { $0.hasSuffix("View.swift") }.sorted(),
                       ["AvatarView.swift", "CensorView.swift", "CommentCardView.swift", "CommentThreadView.swift", "ContentFooterView.swift",
                        "ContentHeaderView.swift", "ContentMenuView.swift", "ContentStateView.swift", "MarkdownBodyView.swift"])
        XCTAssertTrue(names(thread).contains("SocialSwipe.swift"), "swipe to reply needs both features")
        XCTAssertFalse(names(thread).contains("PostCardView.swift"))
        XCTAssertNil(thread.schema)
        XCTAssertEqual(thread.notes.count, 1, "the call is told nothing is mapped")
        let footer = try Fixture.text(thread.paths, "ContentFooterView.swift")
        XCTAssertTrue(footer.contains("actions.vote"))
        XCTAssertFalse(footer.contains("actions.save"), "a feature left out is not written")
        XCTAssertFalse(footer.contains("//@"), "no marker reaches the app")
        let actions = try Fixture.text(thread.paths, "SocialActions.swift")
        XCTAssertTrue(actions.contains("var reply:") && !actions.contains("var submit:") && !actions.contains("var search:"))

        let (bare, _) = try write(.init(features: [], screens: [.post]))
        XCTAssertFalse(names(bare).contains("LinkPreviewView.swift") || names(bare).contains("MediaGalleryView.swift") || names(bare).contains("ReportView.swift"))
        XCTAssertFalse(try Fixture.text(bare.paths, "MarkdownBodyView.swift").contains("AttributedString(markdown:"), "plain text without markdown")

        let (all, _) = try write(.init())
        XCTAssertEqual(all.views.count, KitPlan(features: Set(LoomFeature.allCases), screens: LoomScreen.allCases).views.count)
        XCTAssertTrue(names(all).isSuperset(of: ["FeedSplitView.swift", "ReportView.swift", "ShareImageView.swift", "InstanceCardView.swift"]))
    }

    /// The colour sets `colors: assets` reads, in a catalog under `folder`.
    private func catalog(in folder: URL) throws {
        for name in LoomAgent.colorSets {
            let set = folder.appendingPathComponent("Shared/Assets.xcassets/colors/\(name).colorset")
            try FileManager.default.createDirectory(at: set, withIntermediateDirectories: true)
            try "{}".write(to: set.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
        }
    }

    func testTheStyleAndColoursChooseTheDefaults() throws {
        let folder = try Fixture.folder()
        try catalog(in: folder)
        let reader = try LoomAgent.write(.init(style: .reader, colors: .assets, screens: [], directory: folder.path), note: { _ in }, yield: { _ in })
        let style = try Fixture.text(reader.paths, "SocialStyle.swift")
        XCTAssertTrue(style.contains("static let defaultValue: SocialStyle = .reader"))
        XCTAssertEqual(style.components(separatedBy: "static let defaultValue").count, 2)
        XCTAssertTrue(style.contains("Color(\"colors/background\")"))
        XCTAssertFalse(style.contains("socialDynamic"))
        XCTAssertTrue(reader.notes.contains { $0.contains("colors/background") })

        // Without the sets, asset colours would draw clear: the system's are used, and the note says what to add.
        let (bare, _) = try write(.init(colors: .assets, screens: []))
        XCTAssertTrue(try Fixture.text(bare.paths, "SocialStyle.swift").contains("socialDynamic"), "the system's colours")
        XCTAssertTrue(bare.notes.contains { $0.contains("The asset catalog has no colors/background") }, "\(bare.notes)")

        let (loom, _) = try write(.init(screens: []))
        let code = try Fixture.text(loom.paths, "SocialStyle.swift")
        XCTAssertTrue(code.contains("static let defaultValue: SocialStyle = .loom"))
        XCTAssertTrue(code.contains("background: .socialDynamic(light: 0xFFFFFF, dark: 0x121212)"), "Loom's own background")
    }

    func testAPrefixRenamesEveryViewAndItsFile() throws {
        let (result, _) = try write(.init(screens: [.feed], prefix: "Kit"))
        XCTAssertTrue(result.views.allSatisfy { $0.hasPrefix("Kit") })
        XCTAssertTrue(names(result).contains("KitPostCardView.swift"))
        XCTAssertTrue(names(result).contains("SocialStyle.swift"), "support files keep their names")
        let feed = try Fixture.text(result.paths, "KitFeedView.swift")
        XCTAssertTrue(feed.contains("struct KitFeedView<Social: SocialSchema, Accessory: View>: View {"))
        XCTAssertTrue(feed.contains("KitPostCardView(post: post, actions: actions)"))
        XCTAssertFalse(feed.range(of: #"(?<![A-Za-z])PostCardView"#, options: .regularExpression) != nil, "no name left behind")
    }

    func testSwiftThatDoesNotParseIsRefusedBeforeItLands() throws {
        let folder = try Fixture.folder()
        let input = LoomAgent.Input(mappings: ["post: Dish title=value.name ?? ("], screens: [], directory: folder.path)
        XCTAssertThrowsError(try LoomAgent.write(input, note: { _ in }, yield: { _ in })) { error in
            XCTAssertTrue("\(error)".contains("does not parse"), "\(error)")
            XCTAssertTrue("\(error)".contains("Conformances/Dish+Post.swift"), "the file is named as the project knows it: \(error)")
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.appendingPathComponent("Shared").path))
    }
}

/// A template made into a file: blocks kept or dropped, names prefixed whole.
final class TemplateRenderTests: XCTestCase {
    func testBlocksNestElseAndCombine() throws {
        let source = """
        a
        //@if vote
        b
        //@if save || share
        c
        //@else
        d
        //@endif
        //@else
        e
        //@endif
        //@if vote && !reply
        f
        //@endif
        """
        XCTAssertEqual(try TemplateRender.render(source, flags: ["vote", "share"]), "a\nb\nc\nf\n")
        XCTAssertEqual(try TemplateRender.render(source, flags: ["vote", "reply"]), "a\nb\nd\n")
        XCTAssertEqual(try TemplateRender.render(source, flags: []), "a\ne\n")
        XCTAssertThrowsError(try TemplateRender.render("//@if vote\nx", flags: []))
        XCTAssertThrowsError(try TemplateRender.render("x\n//@endif", flags: []))
    }

    func testADroppedBlockLeavesNoBlankLinesBehind() throws {
        let source = "struct A {\n\n    var a = 1\n\n//@if vote\n    var b = 2\n//@endif\n\n}\n\n\nlet c = 3   "
        XCTAssertEqual(try TemplateRender.render(source, flags: []), "struct A {\n    var a = 1\n}\n\nlet c = 3\n")
    }

    func testPrefixingRenamesWholeNamesOnly() {
        let text = "AvatarView(url: u) UserAvatarView MyAvatarViews PostCardView<Social>"
        XCTAssertEqual(TemplateRender.prefixing(text, names: ["AvatarView", "PostCardView"], prefix: "Kit"),
                       "KitAvatarView(url: u) UserAvatarView MyAvatarViews KitPostCardView<Social>")
    }
}

/// Mappings checked against the app's own types (Hearth, 2026-11-01: the model mapped HearthKit's types, and the
/// conformances did not build until it imported HearthKit into five files by hand).
final class AppTypesTests: XCTestCase {
    private func kit() throws -> URL {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("loom-apptypes-\(UUID().uuidString)")
        let sources = folder.appendingPathComponent("Packages/RecipeKit/Sources/RecipeKit")
        try FileManager.default.createDirectory(at: sources, withIntermediateDirectories: true)
        try "// swift-tools-version: 5.9\n".write(to: folder.appendingPathComponent("Packages/RecipeKit/Package.swift"), atomically: true, encoding: .utf8)
        // A hidden file beside the packages: the walk once skipped a folder on reaching one (Margin, 2026-11-01).
        try ".build/\n".write(to: folder.appendingPathComponent(".gitignore"), atomically: true, encoding: .utf8)
        try FileManager.default.createDirectory(at: folder.appendingPathComponent("Components"), withIntermediateDirectories: true)
        try "// a page\n".write(to: folder.appendingPathComponent("Components/.keep"), atomically: true, encoding: .utf8)
        try """
        import Foundation

        public struct Dish: Codable, Identifiable {
            public var id: Int
            public var name: String
            public var createdAt: Date
            public var cook: Cook
            public var replyCount: Int = 0
            public var helper: Cook?
            public var photos: [Photo] = []
            public static let preview = 1

            public init(id: Int) { self.id = id; name = ""; createdAt = .now; cook = Cook(); }
        }

        public struct Cook: Codable {
            public var displayName: String = ""
            public var photoURL: URL?
        }

        public struct Photo: Codable {
            public var width: Int
            public var url: URL?
        }
        """.write(to: sources.appendingPathComponent("Dish.swift"), atomically: true, encoding: .utf8)
        return folder
    }

    func testPathsAreReadInTheTypesSpellingAndItsPackageIsImported() throws {
        let folder = try kit()
        let input = LoomAgent.Input(mappings: ["post: Dish title=name created=created_at author=cook.display_name avatar=cook.photo_url comments=reply_count"],
                                    screens: [.feed], directory: folder.path)
        let result = try LoomAgent.write(input, note: { _ in }, yield: { _ in })
        let conformance = try String(contentsOf: folder.appendingPathComponent("Shared/Views/Social/Conformances/Dish+Post.swift"), encoding: .utf8)
        XCTAssertTrue(conformance.contains("import RecipeKit"), conformance)
        XCTAssertEqual(AppTypes(root: folder).check("helper.displayName", from: "Dish").path, "helper?.displayName", "an optional step reads on with ?.")
        for read in ["self.createdAt", "self.cook.displayName", "self.cook.photoURL", "self.replyCount"] {
            XCTAssertTrue(conformance.contains(read), "\(read) in \(conformance)")
        }
        XCTAssertTrue(result.notes.contains("`Dish` is declared in RecipeKit, so the conformances import it."), "\(result.notes)")
        let media = try LoomAgent.write(LoomAgent.Input(mappings: ["post: Dish title=name media=photos"], screens: [.feed], directory: folder.path), note: { _ in }, yield: { _ in })
        let withMedia = try String(contentsOf: folder.appendingPathComponent("Shared/Views/Social/Conformances/Dish+Post.swift"), encoding: .utf8)
        XCTAssertTrue(withMedia.contains("photos.map(\\.url)"), withMedia)
        _ = try LoomAgent.write(LoomAgent.Input(mappings: ["post: Dish title=name mine=helper.displayName==name"], screens: [.feed], directory: folder.path), note: { _ in }, yield: { _ in })
        let mine = try String(contentsOf: folder.appendingPathComponent("Shared/Views/Social/Conformances/Dish+Post.swift"), encoding: .utf8)
        XCTAssertTrue(mine.contains("helper?.displayName==name"), "an expression reads through an optional too: \(mine)")
        XCTAssertTrue(media.notes.contains { $0.contains("each Photo's `url` is read as its link") }, "\(media.notes)")
        XCTAssertTrue(result.notes.contains { $0.contains("`created_at` is `createdAt` on Dish") }, "\(result.notes)")
    }

    func testAFieldTheTypeDoesNotHaveIsRefusedWithItsFields() throws {
        let folder = try kit()
        let input = LoomAgent.Input(mappings: ["post: Dish title=name score=likes"], screens: [.feed], directory: folder.path)
        XCTAssertThrowsError(try LoomAgent.write(input, note: { _ in }, yield: { _ in })) { error in
            let text = "\(error)"
            XCTAssertTrue(text.contains("post score=likes: `Dish` has no `likes`: its fields are id, name, createdAt, cook, replyCount, helper, photos"), text)
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.appendingPathComponent("Shared/Views/Social").path))
    }
}

/// A type named as its role is reached through a file-level name, so the schema never names itself (Margin).
final class SchemaNamesTests: XCTestCase {
    func testATypeNamedAsItsRoleDoesNotNameItself() {
        let text = ConformanceEmitter.schema([.post: "Post", .comment: "Comment", .user: "Reader"], imports: [])
        XCTAssertTrue(text.contains("typealias AppSocialComment = Comment"), text)
        XCTAssertTrue(text.contains("    typealias Comment = AppSocialComment"), text)
        XCTAssertTrue(text.contains("    typealias User = Reader"), text)
        XCTAssertFalse(text.contains("typealias Post = Post"), text)
    }
}
