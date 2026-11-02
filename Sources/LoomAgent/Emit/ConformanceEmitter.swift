//  WHAT: The files that make an app's types the views' types: one extension a mapping line, each mapped property a
//        computed requirement that reads the type through `SocialValue`, and `AppSocial`, the schema naming one
//        type a role (this call's lines, and the roles an earlier call's conformances already give).
//  PIN:  AN UNMAPPED PROPERTY IS NOT WRITTEN: the protocol's default answers for it, so a conformance holds only
//        what the line says. An `id` the type already has is never redeclared.
//  PIN:  ONE TYPE, SEVERAL ROLES (a status that is a post and a reply): a requirement two of its protocols share is
//        written once, from the line that maps it or as its default, since Swift will not choose between two
//        protocols' defaults for one type.

import Foundation

enum ConformanceEmitter {
    /// The schema's name, as the app's code spells it: `SocialActions<AppSocial>`.
    static let schemaName = "AppSocial"

    /// One file a mapping line, `<Type>+<Role>.swift`: `extension Post: PostRepresentable { … }`. The lines of one
    /// type are read together, and a member two of its roles share is written once, in its first role's file.
    /// Answers the files, or every reason the lines of one type disagree.
    static func emit(_ mappings: [Mapping], imports: [String]) -> (files: [(name: String, text: String)], problems: [String]) {
        var files: [(name: String, text: String)] = [], problems: [String] = []
        var types: [String] = []
        for mapping in mappings where !types.contains(mapping.type) { types.append(mapping.type) }
        for type in types {
            let lines = mappings.filter { $0.type == type }.sorted { order($0.role) < order($1.role) }
            var kinds: [String: SocialKind] = [:], owners: [String: [SocialRole]] = [:]
            for line in lines {
                for property in line.role.properties {
                    if let kind = kinds[property.member], kind != property.kind {
                        let roles = (owners[property.member] ?? []) + [line.role]
                        problems.append("`\(type)` cannot be both a \(roles.map(\.rawValue).joined(separator: " and a ")): they show `\(property.key)` differently")
                    }
                    kinds[property.member] = property.kind
                    owners[property.member, default: []].append(line.role)
                }
            }
            let shared = Set(owners.filter { $0.value.count > 1 }.keys)
            var sharedSources: [String: Mapping.Source] = [:]
            var ids: [Mapping.Source] = []
            for line in lines {
                if let id = line.id, !ids.contains(id) { ids.append(id) }
                for assignment in line.assignments where shared.contains(assignment.property.member) {
                    let member = assignment.property.member
                    if let source = sharedSources[member], source != assignment.source {
                        problems.append("`\(type)` maps `\(assignment.property.key)` one way as a \(lines[0].role.rawValue) and another as a \(line.role.rawValue): say it the same way in both lines")
                    }
                    sharedSources[member] = assignment.source
                }
            }
            if ids.count > 1 { problems.append("`\(type)` maps `id` differently in its lines: say it the same way in each") }
            for (index, line) in lines.enumerated() {
                var body: [String] = []
                if index == 0 {
                    if let id = ids.first, id != .path("id") {
                        // `Identifiable` is public, so a public type's `id` must be too; on an internal type it is internal.
                        body.append("    /// Identifies it to the views; public because `Identifiable` asks that of a public type.")
                        body += getter("id", type: "String", conversion: "id", source: id, access: "public ")
                    }
                    // Every shared member once: as a line maps it, or as its default.
                    for property in sharedProperties(lines, shared) {
                        if let source = sharedSources[property.member] {
                            body += getter(property.member, type: property.kind.swiftType, conversion: property.kind.conversion, source: source)
                        } else {
                            body.append("    var \(property.member): \(property.kind.swiftType) { \(property.kind.defaultValue) }")
                        }
                    }
                }
                for assignment in line.assignments where !shared.contains(assignment.property.member) {
                    let property = assignment.property
                    body += getter(property.member, type: property.kind.swiftType, conversion: property.kind.conversion, source: assignment.source)
                }
                var text = header(imports)
                text += [
                    "/// \(article(type).capitalized) `\(type)` as the social views show \(line.role == .user ? "a person" : "it").",
                    "extension \(type): \(line.role.protocolName) {",
                ]
                text += body
                text.append("}")
                files.append((name: "\(line.fileStem)+\(line.role.name).swift", text: text.joined(separator: "\n") + "\n"))
            }
        }
        return (files, problems)
    }

    /// The members `lines`' roles share, once each, in the first role's order.
    private static func sharedProperties(_ lines: [Mapping], _ shared: Set<String>) -> [SocialProperty] {
        var seen: Set<String> = [], properties: [SocialProperty] = []
        for line in lines {
            for property in line.role.properties where shared.contains(property.member) && seen.insert(property.member).inserted {
                properties.append(property)
            }
        }
        return properties
    }

    private static func order(_ role: SocialRole) -> Int { SocialRole.allCases.firstIndex(of: role) ?? 0 }

    /// `enum AppSocial: SocialSchema`, one type a role, a stand-in for a role nothing maps.
    static func schema(_ types: [SocialRole: String], imports: [String]) -> String {
        var lines = header(imports)
        // A type named as its role (`Comment`) would read `typealias Comment = Comment` inside the schema, which names
        // itself (Margin, 2026-11-01): it is reached through a file-level name instead.
        let same = SocialRole.allCases.filter { types[$0] == $0.name }
        for role in same { lines.append("typealias \(schemaName)\(role.name) = \(role.name)") }
        if !same.isEmpty { lines.append("") }
        lines += [
            "/// The app's types, as the social views know them: `FeedView(posts:actions:)` with `SocialActions<\(schemaName)>`.",
            "enum \(schemaName): SocialSchema {",
        ]
        for role in SocialRole.allCases {
            let type = types[role] ?? role.absentType
            lines.append("    typealias \(role.name) = \(type == role.name ? schemaName + role.name : type)")
        }
        lines.append("}")
        return lines.joined(separator: "\n") + "\n"
    }

    /// The roles and imports of conformances an earlier call wrote into `folder`, so the schema keeps them.
    static func earlier(in folder: URL) -> (types: [SocialRole: String], imports: [String]) {
        guard let names = try? FileManager.default.contentsOfDirectory(atPath: folder.path) else { return ([:], []) }
        var types: [SocialRole: String] = [:]
        var imports: [String] = []
        for name in names.sorted() where name.hasSuffix(".swift") && name != schemaName + ".swift" {
            guard let text = try? String(contentsOf: folder.appendingPathComponent(name), encoding: .utf8) else { continue }
            for role in SocialRole.allCases {
                let pattern = #"extension\s+([A-Za-z0-9_.]+)\s*:\s*"# + role.protocolName + #"\b"#
                if let range = text.range(of: pattern, options: .regularExpression) {
                    let declaration = String(text[range])
                    if let type = declaration.split(whereSeparator: { $0 == " " || $0 == ":" || $0 == "\n" }).dropFirst().first {
                        types[role] = String(type)
                    }
                }
            }
            for line in text.split(separator: "\n") where line.hasPrefix("import ") {
                let module = String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                if module != "Foundation", !imports.contains(module) { imports.append(module) }
            }
        }
        return (types, imports)
    }

    // MARK: Lines

    private static func header(_ imports: [String]) -> [String] {
        (["Foundation"] + imports.filter { $0 != "Foundation" }).map { "import \($0)" } + [""]
    }

    /// A computed requirement: a bare path read off the type, or an expression that names `value`.
    private static func getter(_ member: String, type: String, conversion: String, source: Mapping.Source,
                               access: String = "") -> [String] {
        switch source {
        case .path(let path):
            return ["    \(access)var \(member): \(type) { SocialValue.\(conversion)(self.\(path)) }"]
        case .expression(let expression):
            guard expression.range(of: #"(?<![A-Za-z0-9_.])value(?![A-Za-z0-9_])"#, options: .regularExpression) != nil else {
                return ["    \(access)var \(member): \(type) { SocialValue.\(conversion)(\(expression)) }"]
            }
            return [
                "    \(access)var \(member): \(type) {",
                "        let value = self",
                "        return SocialValue.\(conversion)(\(expression))",
                "    }",
            ]
        }
    }

    private static func article(_ word: String) -> String {
        guard let first = word.first?.lowercased() else { return "a" }
        return "aeiou".contains(first) ? "an" : "a"
    }
}
