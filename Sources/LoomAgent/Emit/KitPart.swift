//  WHAT: One file of the kit a call can write: its template, the views it declares, the parts it uses, and when
//        it is written at all.

import Foundation

struct KitPart: Sendable {
    /// The file's name without `.swift`, and its flag in templates: `part.PostCardView`.
    let name: String
    /// The view types it declares, which the call's prefix renames.
    let views: [String]
    let template: String
    /// The parts it always uses.
    let needs: [String]
    /// Parts it uses only when every one of a set of features is on.
    let needsWhen: [(features: Set<LoomFeature>, part: String)]
    /// A feature without which it is never written.
    let feature: LoomFeature?

    init(_ name: String, views: [String] = [], needs: [String] = [], when: [(Set<LoomFeature>, String)] = [],
         feature: LoomFeature? = nil, _ template: String) {
        self.name = name; self.views = views; self.needs = needs; self.feature = feature; self.template = template
        self.needsWhen = when.map { (features: $0.0, part: $0.1) }
    }

    /// Whether the call's prefix goes on the file's name: a file named for the view it declares.
    var isView: Bool { views.contains(name) }
}
