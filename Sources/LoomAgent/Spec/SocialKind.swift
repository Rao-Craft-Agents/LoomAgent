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
