//  WHAT: The app's own types, read off its Swift: each declared struct, class, enum or actor, its stored fields and
//        their types, and the module it is in when a local package declares it (`Packages/<Kit>/Sources/<Module>/`).
//        A call reads it to check each mapping's path and to import a mapped type's package.
//  PIN:  READ, NOT COMPILED. Declarations are found by their shape on a line; a type it does not find (a remote
//        package's, Foundation's) is taken as the line wrote it, never refused.

import Foundation

struct AppTypes {
    struct Declared {
        let name: String
        /// Stored fields in order, with their types as written: `created_at: Date`, `author: User`.
        var fields: [(name: String, type: String)] = []
        /// The local package's module that declares it; nil for the app's own.
        var module: String?

        func field(_ name: String) -> String? { fields.first { $0.name == name }?.type }
    }

    var types: [String: Declared] = [:]

    init() {}

    /// Every Swift file under `root`, skipping build products, tests and project bundles.
    /// `excluding`: a folder whose types are not the app's (the kit loom writes, whose previews declare a `Comment`).
    init(root: URL, excluding: URL? = nil) {
        let skipped: Set<String> = [".build", ".git", ".swiftpm", "DerivedData", "node_modules", "Tests", "UITests"]
        guard let walker = FileManager.default.enumerator(at: root, includingPropertiesForKeys: [.isDirectoryKey]) else { return }
        for case let url as URL in walker {
            let name = url.lastPathComponent
            if let excluding, url.standardizedFileURL.path.hasPrefix(excluding.standardizedFileURL.path + "/") || url.standardizedFileURL.path == excluding.standardizedFileURL.path {
                walker.skipDescendants(); continue
            }
            // Only a folder is skipped: on a file, skipDescendants skips the folder entered last, which hid a whole
            // package from this reader (Margin, 2026-11-01).
            let isFolder = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isFolder, skipped.contains(name) || name.hasPrefix(".") || name.hasSuffix(".xcodeproj") || name.hasSuffix(".xcassets") || name.hasSuffix("Tests") {
                walker.skipDescendants(); continue
            }
            guard url.pathExtension == "swift", let text = try? String(contentsOf: url, encoding: .utf8) else { continue }
            read(text, module: Self.module(of: url))
        }
    }

    /// The declarations of one file: a type at the start of a line, its stored `let`/`var` fields one level in.
    mutating func read(_ text: String, module: String?) {
        let lines = text.components(separatedBy: "\n")
        let declaration = #"^(?:(?:public|internal|fileprivate|private|open|final|@\w+)\s+)*(struct|class|enum|actor)\s+([A-Z][A-Za-z0-9_]*)"#
        let field = #"^\s+(?:(?:public|internal|fileprivate|private|open|@\w+(?:\([^)]*\))?)\s+)*(?:let|var)\s+([a-z_][A-Za-z0-9_]*)\s*:\s*([^={]+?)\s*(?:=.*)?$"#
        var current: Declared?
        var depth = 0
        func close() { if let done = current, types[done.name] == nil || types[done.name]?.fields.isEmpty == true { types[done.name] = done }; current = nil }
        for line in lines {
            if depth == 0, let match = line.range(of: declaration, options: .regularExpression) {
                close()
                let words = line[match].split(separator: " ")
                if let name = words.last.map(String.init) { current = Declared(name: name, module: module) }
            } else if depth == 1, current != nil, !line.contains("static "), !line.contains("{"),
                      let match = line.range(of: field, options: .regularExpression) {
                let text = String(line[match])
                if let colon = text.firstIndex(of: ":") {
                    let left = text[..<colon].split(separator: " ").last.map(String.init) ?? ""
                    var type = text[text.index(after: colon)...].trimmingCharacters(in: .whitespaces)
                    if let equals = type.firstIndex(of: "=") { type = type[..<equals].trimmingCharacters(in: .whitespaces) }
                    if !left.isEmpty, !type.isEmpty { current?.fields.append((left, type)) }
                }
            }
            depth += line.filter { $0 == "{" }.count - line.filter { $0 == "}" }.count
            if depth <= 0 { depth = 0; if !line.contains("{") { continue } }
        }
        close()
    }

    /// The module a file of a local package compiles into: the folder under `Sources/`, when a Package.swift is above.
    static func module(of url: URL) -> String? {
        let parts = url.pathComponents
        guard let sources = parts.lastIndex(of: "Sources"), sources + 1 < parts.count - 1,
              FileManager.default.fileExists(atPath: NSString.path(withComponents: Array(parts[..<sources])) + "/Package.swift") else { return nil }
        return parts[sources + 1]
    }

    /// The type a field's type names: `User` in `User?`, `[User]` and `Array<User>`.
    static func named(_ type: String) -> String {
        var text = type.replacingOccurrences(of: " ", with: "")
        while text.hasSuffix("?") || text.hasSuffix("!") { text.removeLast() }
        if text.hasPrefix("["), text.hasSuffix("]"), !text.contains(":") { text = String(text.dropFirst().dropLast()) }
        if let open = text.firstIndex(of: "<"), text.hasSuffix(">") { text = String(text[text.index(after: open)..<text.index(before: text.endIndex)]) }
        return text.split(separator: ".").last.map(String.init) ?? text
    }

    /// The field a path's step names on `type`, as the line wrote it or in Swift's spelling (`created_at` is
    /// `createdAt`, `post_id` is `postID`); nil when the type has neither.
    func field(_ step: String, on type: Declared) -> String? {
        if type.field(step) != nil { return step }
        let parts = step.split(separator: "_").map(String.init)
        guard parts.count > 1 else { return nil }
        let camel = parts[0] + parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
        let initialisms = parts[0] + parts.dropFirst().map { ["id", "url", "uri", "html", "json", "api"].contains($0) ? $0.uppercased() : $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
        return [camel, initialisms].first { type.field($0) != nil }
    }

    /// The element type of the list a path ends on, when it is one of the app's types: `MediaAttachment` for `media`.
    func listElement(of path: String, from type: String) -> String? {
        guard var current = types[Self.named(type)] else { return nil }
        let steps = path.components(separatedBy: ".").map { $0.hasSuffix("?") ? String($0.dropLast()) : $0 }
        for (index, step) in steps.enumerated() {
            guard let fieldType = current.field(step) else { return nil }
            let text = fieldType.replacingOccurrences(of: " ", with: "")
            if index == steps.count - 1 {
                guard text.hasPrefix("["), !text.contains(":") else { return nil }
                let element = Self.named(text)
                return types[element] == nil ? nil : element
            }
            guard let next = types[Self.named(text)] else { return nil }
            current = next
        }
        return nil
    }

    /// A mapping's path, checked against the app's types: each step a field of the type before it, in the type's
    /// spelling. The path as it should be written, and why not, when a step names no field. Steps past a type it does
    /// not know are kept as written.
    func check(_ path: String, from type: String) -> (path: String, problem: String?) {
        guard var current = types[Self.named(type)] else { return (path, nil) }
        var out: [String] = []
        let steps = path.components(separatedBy: ".")
        for (index, raw) in steps.enumerated() {
            let optional = raw.hasSuffix("?") ? "?" : ""
            let step = optional.isEmpty ? raw : String(raw.dropLast())
            guard let found = field(step, on: current) else {
                let known = current.fields.map(\.name).joined(separator: ", ")
                return (path, "`\(current.name)` has no `\(step)`" + (known.isEmpty ? "" : ": its fields are \(known)"))
            }
            // A step through an optional reads on with `?.` (`author?.name` when author is `User?`, Margin 2026-11-01).
            let throughOptional = optional.isEmpty && index < steps.count - 1 && (current.field(found) ?? "").trimmingCharacters(in: .whitespaces).hasSuffix("?")
            out.append(found + (throughOptional ? "?" : optional))
            guard let next = types[Self.named(current.field(found) ?? "")] else {
                out += steps.dropFirst(index + 1)
                break
            }
            current = next
        }
        return (out.joined(separator: "."), nil)
    }
}
