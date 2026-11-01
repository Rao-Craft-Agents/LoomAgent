import Foundation

/// What a run says as it goes.
public enum LoomFrame: Sendable {
    /// The call was read: how many mapping lines, and how many views it writes.
    case read(mappings: Int, views: Int)
    /// The files are written.
    case written(LoomResult)

    public var result: LoomResult? {
        if case .written(let result) = self { return result }
        return nil
    }
}
