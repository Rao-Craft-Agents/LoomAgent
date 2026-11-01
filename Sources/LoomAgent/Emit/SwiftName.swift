//  WHAT: What Swift accepts as a name: a type, a type with its module, a module, a prefix for type names.

import Foundation

enum SwiftName {
    static func isTypeName(_ text: String) -> Bool {
        text.range(of: #"^[A-Z][A-Za-z0-9_]*$"#, options: .regularExpression) != nil
    }

    /// `Post`, `LemmyKit.PostView`: type names joined by dots.
    static func isTypePath(_ text: String) -> Bool {
        !text.isEmpty && text.split(separator: ".", omittingEmptySubsequences: false).allSatisfy { isTypeName(String($0)) }
    }

    /// `LemmyKit`, `Foundation`: what an `import` names.
    static func isModuleName(_ text: String) -> Bool {
        text.range(of: #"^[A-Za-z_][A-Za-z0-9_]*$"#, options: .regularExpression) != nil
    }
}
