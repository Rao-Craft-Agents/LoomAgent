import Foundation
import XCTest
@testable import LoomAgent

/// The templates held to the catalog and the role table, so no call can write a file that reads a requirement that
/// does not exist, leaves a view unprefixed, or keeps a marker.
final class TemplateTests: XCTestCase {
    private var templates: [(name: String, text: String)] {
        KitCatalog.parts.map { ($0.name, $0.template) } + [("SocialProtocolsTail", Template.socialProtocolsTail)]
    }

    func testEveryTemplateRendersWithEveryFlagAndWithNone() throws {
        let all = KitPlan(features: Set(LoomFeature.allCases), screens: LoomScreen.allCases).flags
            .union(["style.loom", "colors.code"])
        for (name, text) in templates {
            for flags in [all, Set<String>()] {
                let rendered = try TemplateRender.render(text, flags: flags)
                XCTAssertFalse(rendered.contains("//@"), "\(name) keeps a marker")
            }
        }
    }

    func testEveryRequirementATemplateReadsIsInTheRoleTable() {
        let requirements = Set(SocialRole.allCases.flatMap { $0.properties.map(\.member) })
        let support: Set<String> = ["socialStyle", "socialContext", "socialDynamic", "socialSystem", "socialSwipe", "socialPalette", "socialRefreshable"]
        for (name, text) in templates {
            let found = matches(#"\bsocial[A-Z][A-Za-z]*"#, in: text)
            for member in found where !requirements.contains(member) && !support.contains(member) {
                XCTFail("\(name) reads \(member), which no role declares")
            }
        }
    }

    func testEveryViewATemplateDeclaresIsPrefixedWithIt() {
        for part in KitCatalog.parts {
            let declared = matches(#"(?m)^struct ([A-Z][A-Za-z]*)(?:<[^>]*>)?: View(?![A-Za-z])"#, in: part.template, group: 1)
            XCTAssertEqual(Set(declared), Set(part.views), "\(part.name) declares \(declared), lists \(part.views)")
        }
    }

    func testEveryPartTheCatalogNamesExists() {
        let names = Set(KitCatalog.parts.map(\.name))
        for part in KitCatalog.parts {
            for need in part.needs + part.needsWhen.map(\.part) { XCTAssertTrue(names.contains(need), "\(part.name) needs \(need)") }
        }
        for name in KitCatalog.core { XCTAssertTrue(names.contains(name), name) }
        for screen in LoomScreen.allCases {
            for root in KitCatalog.roots(of: screen) { XCTAssertTrue(names.contains(root), "\(screen) is built from \(root)") }
        }
    }

    func testTheProtocolFileDeclaresEveryRequirementWithItsDefault() {
        let text = ProtocolsEmitter.emit()
        for role in SocialRole.allCases {
            XCTAssertTrue(text.contains("protocol \(role.protocolName): Identifiable {"))
            XCTAssertTrue(text.contains("associatedtype \(role.name): \(role.protocolName)"))
            XCTAssertTrue(text.contains("enum \(role.absentType): \(role.protocolName)"), "a stand-in for \(role)")
            for property in role.properties {
                XCTAssertTrue(text.contains("    var \(property.member): \(property.kind.swiftType) { get }"), property.member)
                XCTAssertTrue(text.contains("    var \(property.member): \(property.kind.swiftType) { \(property.kind.defaultValue) }"), property.member)
            }
        }
    }

    /// Whatever a call leaves out, the files read as written by hand: no blank-line runs, no blank line against a
    /// brace, no trailing spaces, one newline at the end.
    func testEveryFileIsTidyWhateverTheCallLeavesOut() throws {
        let calls: [(Set<LoomFeature>, [LoomScreen])] = [
            (Set(LoomFeature.allCases), LoomScreen.allCases), ([], LoomScreen.allCases), ([.vote, .markdown], [.thread, .compose]),
        ]
        for (features, screens) in calls {
            let plan = KitPlan(features: features, screens: screens)
            for part in plan.parts {
                let text = try TemplateRender.render(part.template, flags: plan.flags.union(["style.loom", "colors.code"]))
                XCTAssertFalse(text.contains("\n\n\n"), "\(part.name) has a run of blank lines")
                XCTAssertNil(text.range(of: #"\{\n\n|\n\n\s*\}"#, options: .regularExpression), "\(part.name) has a blank line against a brace")
                XCTAssertNil(text.range(of: #"[ \t]\n"#, options: .regularExpression), "\(part.name) has trailing spaces")
                XCTAssertTrue(text.hasSuffix("}\n") || text.hasSuffix(")\n"), "\(part.name) ends with one newline")
            }
        }
        let protocols = ProtocolsEmitter.emit()
        XCTAssertTrue(protocols.hasSuffix("}\n") && !protocols.contains("\n\n\n"))
    }

    /// Every user-facing literal is natural English: no SCREAMING_KEYS reach the app.
    func testNoTemplateWritesAScreamingKey() {
        for (name, text) in templates {
            for key in matches(#"Text\("([A-Z0-9_]{4,})"\)"#, in: text, group: 1) { XCTFail("\(name) shows the key \(key)") }
        }
    }

    private func matches(_ pattern: String, in text: String, group: Int = 0) -> [String] {
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return expression.matches(in: text, range: range).compactMap { match in
            Range(match.range(at: group), in: text).map { String(text[$0]) }
        }
    }
}

/// Every file that declares a view previews it, from the sample types and not the app's.
final class TemplatePreviewTests: XCTestCase {
    func testEveryViewFileHasAPreviewFromTheSamples() {
        for part in KitCatalog.parts where !part.views.isEmpty {
            XCTAssertTrue(part.template.contains("#Preview"), "\(part.name) has no #Preview")
            XCTAssertFalse(part.template.contains("AppSocial"), "\(part.name) previews the app's types")
        }
    }
}
