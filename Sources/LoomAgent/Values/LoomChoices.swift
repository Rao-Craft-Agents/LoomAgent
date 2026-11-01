import Foundation

/// The look the views start in. All three are written; the app may switch at run time (`.socialStyle(_:)`).
public enum LoomStyle: String, Codable, Sendable, CaseIterable {
    /// Loom's own look: its spacing layers, its card, and its colour roles for light and dark.
    case loom
    /// A timeline: an avatar column, content edge to edge, counts beside the actions.
    case social
    /// A compact list with thumbnails and scores, as a link aggregator reads.
    case reader
}

/// Where the colour roles come from.
public enum LoomColors: String, Codable, Sendable, CaseIterable {
    /// Defined in code, dynamic for light and dark, so the app needs no asset: the default.
    case code
    /// Read from the app's asset catalog by name (`colors/background`, `colors/foreground`, …).
    case assets
}

/// A part of the UI a call may leave out; every one is written when the call names none.
public enum LoomFeature: String, Codable, Sendable, CaseIterable {
    case vote, save, share, reply, report, block, nsfwShield, markdown, linkPreview, media, swipeActions, editing
}

/// A screen and the parts it needs; every one is written when the call names none.
public enum LoomScreen: String, Codable, Sendable, CaseIterable {
    case feed, post, thread, compose, reply, profile, community, search, instances, filter, share
}
