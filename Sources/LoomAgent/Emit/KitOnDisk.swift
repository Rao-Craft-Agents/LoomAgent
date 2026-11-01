//  WHAT: The kit an earlier call left in the folder: its parts, its view prefix, the features its files show, and
//        the look its style file starts in. A later call plans with all of it, so the files every view shares
//        (`SocialActions`, `SocialPreviews`, `SocialStyle`) still hold what the earlier views use.
//  PIN:  A LATER CALL ADDS, IT NEVER TAKES AWAY. Its parts and features join the folder's; its look and colours
//        replace the folder's only when it names them. Views keep one prefix a folder.

import Foundation

struct KitOnDisk: Sendable {
    /// The parts whose files are in the folder.
    var parts: [String] = []
    /// The prefix its view files carry; nil when it holds no view.
    var prefix: String?
    var features: Set<LoomFeature> = []
    var style: LoomStyle?
    var colors: LoomColors?

    /// Whether the folder holds a kit at all.
    var isEmpty: Bool { parts.isEmpty }

    static func read(_ folder: URL) -> KitOnDisk {
        let manager = FileManager.default
        guard let names = try? manager.contentsOfDirectory(atPath: folder.path),
              names.contains("SocialProtocols.swift") else { return KitOnDisk() }
        var kit = KitOnDisk()
        func text(_ name: String) -> String { (try? String(contentsOf: folder.appendingPathComponent(name), encoding: .utf8)) ?? "" }

        // The prefix that names the most view files: an app's own `UserAvatarView.swift` beside the kit is outvoted.
        var votes: [String: Int] = [:]
        for part in KitCatalog.parts where part.isView {
            for name in names where name.hasSuffix(part.name + ".swift") {
                let prefix = String(name.dropLast(part.name.count + 6))
                if prefix.isEmpty || SwiftName.isTypeName(prefix) { votes[prefix, default: 0] += 1 }
            }
        }
        kit.prefix = votes.max { $0.value < $1.value || ($0.value == $1.value && $0.key > $1.key) }?.key
        let prefix = kit.prefix ?? ""
        for part in KitCatalog.parts where names.contains((part.isView ? prefix : "") + part.name + ".swift") {
            kit.parts.append(part.name)
        }

        let actions = text("SocialActions.swift")
        let shown: [(LoomFeature, Bool)] = [
            (.vote, actions.contains("var vote:")), (.save, actions.contains("var save:")), (.share, actions.contains("var share:")),
            (.reply, actions.contains("var reply:")), (.report, actions.contains("var report:")), (.block, actions.contains("var block:")),
            (.editing, actions.contains("var edit:")),
            (.markdown, text(prefix + "MarkdownBodyView.swift").contains("AttributedString(markdown:")),
            (.linkPreview, kit.parts.contains("LinkPreviewView")), (.media, kit.parts.contains("MediaGalleryView")),
            (.swipeActions, kit.parts.contains("SocialSwipe")),
            (.nsfwShield, text(prefix + "PostCardView.swift").contains("revealed")),
        ]
        kit.features = Set(shown.filter(\.1).map(\.0))

        let style = text("SocialStyle.swift")
        if let range = style.range(of: #"defaultValue: SocialStyle = \.[a-z]+"#, options: .regularExpression) {
            kit.style = LoomStyle(rawValue: String(style[range].split(separator: ".").last ?? ""))
        }
        kit.colors = style.isEmpty ? nil : style.contains("Color(\"colors/background\")") ? .assets : .code
        return kit
    }
}
