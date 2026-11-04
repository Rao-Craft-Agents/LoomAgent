import Foundation
import GraniteAgents

/// What a call answers, as `granite-answer/1`: the files written, as absolute paths, what the app uses them by, and
/// what the call made of the screens and mapping lines it was asked for.
public struct LoomResult: AgentAnswer, Equatable {
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
    /// Each view and conformance written.
    public var made: [AgentMade]
    /// The views the screens asked for are built from, and one conformance a mapping line.
    public var expected: [AgentExpected]
    /// What it could only do in part: the system's colours where the asset catalog had none.
    public var problems: [AgentProblem]

    public init(path: String?, paths: [String], views: [String], conformances: [String], schema: String?, notes: [String],
                made: [AgentMade] = [], expected: [AgentExpected] = [], problems: [AgentProblem] = []) {
        self.path = path; self.paths = paths; self.views = views; self.conformances = conformances; self.schema = schema
        self.notes = notes; self.made = made; self.expected = expected; self.problems = problems
    }
}
