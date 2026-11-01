import XCTest
@testable import LoomAgent

/// The line a model writes, read: every form the guide promises, and a reason for every line refused.
final class MappingLineTests: XCTestCase {
    func testALineOfBarePaths() throws {
        let mapping = try MappingLine.parse("post: Dish title=name author=cook.name score=stats?.likes comments=replyCount")
        XCTAssertEqual(mapping.role, .post)
        XCTAssertEqual(mapping.type, "Dish")
        XCTAssertNil(mapping.id)
        XCTAssertEqual(mapping.assignments.map(\.property.member), ["socialTitle", "socialAuthorName", "socialScore", "socialCommentCount"])
        XCTAssertEqual(mapping.assignments.map(\.source), [.path("name"), .path("cook.name"), .path("stats?.likes"), .path("replyCount")])
    }

    func testExpressionsKeepTheirSpacesQuotesAndComparisons() throws {
        let mapping = try MappingLine.parse(#"community: Club title=value.name ?? "Untitled" subscribed=value.state == "joined", nsfw = rating >= 18 icon=URL(string: value.badge)"#)
        XCTAssertEqual(mapping.assignments.map(\.source), [
            .expression(#"value.name ?? "Untitled""#),
            .expression(#"value.state == "joined""#),
            .expression("rating >= 18"),
            .expression("URL(string: value.badge)"),
        ])
    }

    func testIdAliasesModulesAndRootsAreRead() throws {
        let mapping = try MappingLine.parse("Account: Feed.Member id=member.id username=value.handle picture=self.photo")
        XCTAssertEqual(mapping.role, .user, "`account` is a user")
        XCTAssertEqual(mapping.type, "Feed.Member")
        XCTAssertEqual(mapping.fileStem, "FeedMember")
        XCTAssertEqual(mapping.id, .path("member.id"))
        XCTAssertEqual(mapping.assignments.map(\.property.key), ["name", "avatar"], "aliases name their property")
        XCTAssertEqual(mapping.assignments.map(\.source), [.path("handle"), .path("photo")], "`value.` and `self.` are the value")
    }

    func testLinesThatAreRefusedSayWhy() {
        let refused: [(String, String)] = [
            ("post Dish title=name", "has no colon"),
            ("recipe: Dish title=name", "is not a role"),
            ("post: dish title=name", "is not a type name"),
            ("post: Box<Dish> title=name", "is not a type name"),
            ("post: Dish flavour=salty", "a post maps id, title, body"),
            ("post: Dish title=name title=label", "`title` is mapped twice"),
            ("post: Dish title=", "has `=` and no value"),
            ("post: Dish", "it maps nothing"),
            ("post: Dish stray title=name", "`stray` is not `word=value`"),
            ("post: Dish id=key id=slug", "`id` is mapped twice"),
        ]
        for (line, reason) in refused {
            XCTAssertThrowsError(try MappingLine.parse(line), line) { error in
                XCTAssertTrue("\(error)".contains(reason), "\(line) → \(error)")
            }
        }
    }

    func testEveryRoleKnowsItsWordsOnce() {
        for role in SocialRole.allCases {
            var words: Set<String> = []
            for property in role.properties {
                for word in [property.key] + property.aliases {
                    XCTAssertTrue(words.insert(word.lowercased()).inserted, "\(role).\(word) names two properties")
                }
                XCTAssertTrue(property.member.hasPrefix("social"), "\(property.member) is namespaced")
                XCTAssertTrue(property.doc.hasSuffix("."), "\(property.member)'s doc is a sentence")
            }
            XCTAssertNotNil(role.property(named: role.properties[0].key.uppercased()), "words are read in any case")
        }
        var roleWords: Set<String> = []
        for role in SocialRole.allCases {
            for word in [role.rawValue] + role.aliases { XCTAssertTrue(roleWords.insert(word).inserted, "\(word) names two roles") }
        }
    }
}
