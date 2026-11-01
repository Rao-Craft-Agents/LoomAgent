import Foundation

/// What a call can say instead of writing.
public enum LoomError: Error, Equatable, CustomStringConvertible {
    /// A mapping line that is not understood, and why.
    case line(String, String)
    /// Every problem with the call at once, so all are fixed in one call: nothing was written.
    case problems([String])

    public var description: String {
        switch self {
        case .line(let line, let reason): return "`\(line)`: \(reason)"
        case .problems(let reasons):
            let count = reasons.count == 1 ? "1 problem" : "\(reasons.count) problems"
            return "\(count) with the call, so nothing was written:\n" + reasons.map { "- \($0)" }.joined(separator: "\n")
        }
    }
}
