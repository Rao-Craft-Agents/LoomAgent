//  WHAT: What a role property holds, and how a mapped value becomes it: its Swift type, its default, and the
//        `SocialValue` conversion a conformance wraps every right side in.
//  PIN:  EVERY RIGHT SIDE IS CONVERTED. An app's `published` may be a `Date`, an ISO string or nothing at all;
//        `SocialValue.date(_:)` has an overload for each, so a bare path compiles whatever the field's type.

import Foundation

enum SocialKind: Sendable, Equatable {
    case text, optionalText, url, urls, int, optionalInt, number, date, flag, vote

    /// The requirement's type in the protocol.
    var swiftType: String {
        switch self {
        case .text: return "String"
        case .optionalText: return "String?"
        case .url: return "URL?"
        case .urls: return "[URL]"
        case .int: return "Int"
        case .optionalInt: return "Int?"
        case .number: return "Double?"
        case .date: return "Date?"
        case .flag: return "Bool"
        case .vote: return "SocialVote"
        }
    }

    /// What a type that does not map the property shows.
    var defaultValue: String {
        switch self {
        case .text: return "\"\""
        case .optionalText, .url, .optionalInt, .number, .date: return "nil"
        case .urls: return "[]"
        case .int: return "0"
        case .flag: return "false"
        case .vote: return ".none"
        }
    }

    /// The field types `SocialValue`'s overloads for this kind take, optional or not, as the template declares them.
    /// A field of another type the app declares, or of a standard type not here, does not compile (Margin, 2026-11-03:
    /// `edited=score` read an `Int` as a flag, and the build failed where the call had passed).
    var takes: Set<String> {
        let integers = Self.integers
        switch self {
        case .text, .optionalText: return integers.union(["String", "Substring", "URL"])
        case .url: return ["URL", "String"]
        case .urls: return ["[URL]", "[URL?]", "[String]", "[String?]", "URL", "String"]
        case .int, .optionalInt: return integers.union(["Double", "String"])
        case .number: return integers.union(["Double", "Duration"])
        case .date: return ["Date", "String", "Double", "Int"]
        case .flag: return ["Bool", "Date", "String"]
        case .vote: return integers.union(["SocialVote", "Bool"])
        }
    }

    /// What `takes` says, in words, for a refusal.
    var takesInWords: String {
        switch self {
        case .text, .optionalText: return "text (a String, a URL or a whole number)"
        case .url: return "a link (a URL or a String)"
        case .urls: return "links (URLs or Strings, one or a list)"
        case .int, .optionalInt: return "a whole number (an Int, a Double or a String)"
        case .number: return "a number (an Int, a Double or a Duration)"
        case .date: return "a date (a Date, an ISO String, or seconds as a Double or an Int)"
        case .flag: return "a flag (a Bool, or a Date or String whose presence sets it)"
        case .vote: return "a vote (a SocialVote, an Int or a Bool)"
        }
    }

    static let integers: Set<String> = ["Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64"]

    /// A right side that says the property has nothing: what leaving it out already shows. `nil` in particular has
    /// no type of its own, so `SocialValue.flag(nil)` cannot choose among `flag`'s optional overloads (Margin,
    /// 2026-11-03: `ambiguous use of 'flag'`).
    func isNothing(_ value: String) -> Bool {
        let text = value.trimmingCharacters(in: .whitespaces)
        return ["nil", "[]", "\"\"", ".none"].contains(text) || text == defaultValue
    }

    /// The `SocialValue` function a mapped value goes through.
    var conversion: String {
        switch self {
        case .text: return "text"
        case .optionalText: return "optionalText"
        case .url: return "url"
        case .urls: return "urls"
        case .int: return "int"
        case .optionalInt: return "optionalInt"
        case .number: return "number"
        case .date: return "date"
        case .flag: return "flag"
        case .vote: return "vote"
        }
    }
}
