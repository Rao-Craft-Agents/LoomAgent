//  WHAT: `SocialProtocols.swift`, made from the role table: the schema, one protocol a role with a default for
//        every requirement, then the vote, the target, what a card reads of a post or a comment, and the types that
//        stand in for a role an app does not have.

import Foundation

enum ProtocolsEmitter {
    static func emit() -> String {
        var lines = [
            "import Foundation",
            "",
            "/// The app's types, as the social views know them: one type a role. Every view is generic over a schema, so it",
            "/// shows the app's own values and hands them back to the app's actions (`SocialActions<AppSocial>`). A role the",
            "/// app does not have is filled by its stand-in, such as `SocialNoCommunity` for a timeline.",
            "protocol SocialSchema {",
        ]
        lines += SocialRole.allCases.map { "    associatedtype \($0.name): \($0.protocolName)" }
        lines.append("}")
        for role in SocialRole.allCases {
            lines += [
                "",
                "/// \(role.doc)",
                "///",
                "/// Every requirement has a default, so a type maps only what it has. The names start with `social` so they",
                "/// never meet the type's own properties.",
                "protocol \(role.protocolName): Identifiable {",
            ]
            for property in role.properties {
                lines.append("    /// \(property.doc)")
                lines.append("    var \(property.member): \(property.kind.swiftType) { get }")
            }
            lines += ["}", "", "extension \(role.protocolName) {"]
            for property in role.properties {
                lines.append("    var \(property.member): \(property.kind.swiftType) { \(property.kind.defaultValue) }")
            }
            lines.append("}")
        }
        return TemplateRender.tidy(lines + Template.socialProtocolsTail.components(separatedBy: "\n"))
    }
}
