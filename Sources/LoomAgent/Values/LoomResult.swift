import Foundation

/// What a call answers: the files written, as absolute paths, and what the app uses them by.
public struct LoomResult: Codable, Sendable, Equatable {
    /// The first file written.
    public var path: String?
    /// Every file written.
    public var paths: [String]
    /// The views written, by type name, in the order a screen is built from them.
    public var views: [String]
    /// One line a mapped type: `PostView: post`.
    public var conformances: [String]
    /// The type that names the app's types for the views (`AppSocial`), when the call mapped any.
    public var schema: String?
    /// One sentence each: what the call left out or the app still has to do, and why.
    public var notes: [String]

    public init(path: String?, paths: [String], views: [String], conformances: [String], schema: String?, notes: [String]) {
        self.path = path; self.paths = paths; self.views = views; self.conformances = conformances; self.schema = schema
        self.notes = notes
    }
}
