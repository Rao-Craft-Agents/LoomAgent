//  WHAT: Which parts a call writes: the core, each screen's parts and every part they use, as far as the call's
//        features allow, in the catalog's order.

import Foundation

struct KitPlan: Sendable {
    let features: Set<LoomFeature>
    let screens: [LoomScreen]
    /// The parts written, in the catalog's order.
    let parts: [KitPart]

    /// The parts of `screens` and of `holding` (what the folder already holds), as far as `features` allow.
    init(features: Set<LoomFeature>, screens: [LoomScreen], holding: [String] = []) {
        self.features = features
        self.screens = screens
        var wanted = Set(KitCatalog.core)
        var stack = KitCatalog.core + screens.flatMap(KitCatalog.roots) + holding
        // A report screen comes with the report feature, wherever a post or a comment is shown.
        if features.contains(.report) { stack.append("ReportView") }
        while let name = stack.popLast() {
            guard let part = KitCatalog.part(name) else { continue }
            if let feature = part.feature, !features.contains(feature) { continue }
            wanted.insert(name)
            let uses = part.needs + part.needsWhen.filter { $0.features.isSubset(of: features) }.map(\.part)
            for use in uses where !wanted.contains(use) { stack.append(use) }
        }
        // A report needs something to report.
        if wanted.contains("ReportView"), !wanted.contains("PostCardView"), !wanted.contains("CommentCardView") {
            wanted.remove("ReportView")
        }
        parts = KitCatalog.parts.filter { wanted.contains($0.name) }
    }

    /// The template flags: each feature, each screen as `screen.X`, each part as `part.X`.
    var flags: Set<String> {
        Set(features.map(\.rawValue)).union(screens.map { "screen.\($0.rawValue)" }).union(parts.map { "part.\($0.name)" })
    }

    /// Every view type written, in order.
    var views: [String] { parts.flatMap(\.views) }
}
