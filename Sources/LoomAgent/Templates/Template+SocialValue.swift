//  WHAT: The template of `SocialValue.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialValue = ##"""
    import Foundation

    /// How an app's values become what the social views show. Every mapped value goes through one of these, so a
    /// field may be a `Date` or an ISO 8601 string, a `URL` or a string, an `Int` or an `Int64`, and still map.
    enum SocialValue {
        // MARK: Text

        static func text(_ value: String) -> String { value }
        static func text(_ value: String?) -> String { value ?? "" }
        static func text<Text: StringProtocol>(_ value: Text) -> String { String(value) }
        static func text<Text: StringProtocol>(_ value: Text?) -> String { value.map { String($0) } ?? "" }
        static func text(_ value: URL) -> String { value.absoluteString }
        static func text(_ value: URL?) -> String { value?.absoluteString ?? "" }
        static func text<Number: BinaryInteger>(_ value: Number) -> String { String(value) }

        static func optionalText(_ value: String) -> String? { value.isEmpty ? nil : value }
        static func optionalText(_ value: String?) -> String? { value.flatMap { $0.isEmpty ? nil : $0 } }
        static func optionalText<Text: StringProtocol>(_ value: Text?) -> String? { value.flatMap { $0.isEmpty ? nil : String($0) } }
        static func optionalText(_ value: URL?) -> String? { value?.absoluteString }
        // An id that is a number (Margin's `parent?.id`, an Int).
        static func optionalText<Number: BinaryInteger>(_ value: Number) -> String? { String(value) }
        static func optionalText<Number: BinaryInteger>(_ value: Number?) -> String? { value.map { String($0) } }

        // MARK: Links

        static func url(_ value: URL) -> URL? { value }
        static func url(_ value: URL?) -> URL? { value }
        static func url(_ value: String?) -> URL? {
            guard let text = value?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
            return URL(string: text)
        }
        static func url(_ value: String) -> URL? { url(Optional(value)) }

        static func urls(_ value: [URL]) -> [URL] { value }
        static func urls(_ value: [URL]?) -> [URL] { value ?? [] }
        static func urls(_ value: [URL?]) -> [URL] { value.compactMap { $0 } }
        static func urls(_ value: [String]) -> [URL] { value.compactMap { url($0) } }
        static func urls(_ value: [String]?) -> [URL] { (value ?? []).compactMap { url($0) } }
        static func urls(_ value: [String?]) -> [URL] { value.compactMap { url($0) } }
        static func urls(_ value: URL?) -> [URL] { value.map { [$0] } ?? [] }
        static func urls(_ value: String?) -> [URL] { url(value).map { [$0] } ?? [] }

        // MARK: Numbers

        static func int(_ value: Int) -> Int { value }
        static func int(_ value: Int?) -> Int { value ?? 0 }
        static func int<Number: BinaryInteger>(_ value: Number) -> Int { Int(clamping: value) }
        static func int<Number: BinaryInteger>(_ value: Number?) -> Int { value.map { Int(clamping: $0) } ?? 0 }
        static func int(_ value: Double?) -> Int { value.map { Int($0.rounded()) } ?? 0 }
        static func int(_ value: String?) -> Int { value.flatMap { Int($0) } ?? 0 }

        static func optionalInt(_ value: Int) -> Int? { value }
        static func optionalInt(_ value: Int?) -> Int? { value }
        static func optionalInt<Number: BinaryInteger>(_ value: Number) -> Int? { Int(clamping: value) }
        static func optionalInt<Number: BinaryInteger>(_ value: Number?) -> Int? { value.map { Int(clamping: $0) } }
        static func optionalInt(_ value: Double?) -> Int? { value.map { Int($0.rounded()) } }
        static func optionalInt(_ value: String?) -> Int? { value.flatMap { Int($0) } }

        static func number(_ value: Double) -> Double? { value }
        static func number(_ value: Double?) -> Double? { value }
        static func number<Number: BinaryInteger>(_ value: Number?) -> Double? { value.map { Double($0) } }
        static func number(_ value: Duration?) -> Double? {
            value.map { Double($0.components.seconds) + Double($0.components.attoseconds) / 1e18 }
        }

        // MARK: Dates

        static func date(_ value: Date) -> Date? { value }
        static func date(_ value: Date?) -> Date? { value }
        static func date(_ value: String) -> Date? { date(Optional(value)) }
        /// An ISO 8601 time (`2023-07-13T12:34:56.123456`, with or without its zone, read as UTC without one), a
        /// day (`2023-07-13`), or seconds since 1970.
        static func date(_ value: String?) -> Date? {
            guard var text = value?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
            if let seconds = Double(text) { return Date(timeIntervalSince1970: seconds) }
            if let time = text.firstIndex(of: "T") {
                let clock = text[text.index(after: time)...]
                if !clock.contains("Z"), !clock.contains("+"), !clock.contains("-") { text += "Z" }
                if let date = try? Date(text, strategy: .iso8601) { return date }
                return try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
            }
            return try? Date(text, strategy: Date.ISO8601FormatStyle().year().month().day())
        }
        static func date(_ seconds: Double?) -> Date? { seconds.map { Date(timeIntervalSince1970: $0) } }
        static func date(_ seconds: Int?) -> Date? { seconds.map { Date(timeIntervalSince1970: TimeInterval($0)) } }

        // MARK: Flags

        static func flag(_ value: Bool) -> Bool { value }
        static func flag(_ value: Bool?) -> Bool { value ?? false }
        /// Set when there is a date: `edited=updated`.
        static func flag(_ value: Date?) -> Bool { value != nil }
        /// Set when there is text: `edited=updated` where `updated` is an ISO string.
        static func flag(_ value: String?) -> Bool { !(value ?? "").isEmpty }

        // MARK: Votes

        static func vote(_ value: SocialVote) -> SocialVote { value }
        static func vote(_ value: Int) -> SocialVote { value > 0 ? .up : value < 0 ? .down : .none }
        static func vote(_ value: Int?) -> SocialVote { vote(value ?? 0) }
        static func vote<Number: BinaryInteger>(_ value: Number?) -> SocialVote { vote(value.map { Int(clamping: $0) } ?? 0) }
        /// A like is an upvote.
        static func vote(_ value: Bool) -> SocialVote { value ? .up : .none }
        static func vote(_ value: Bool?) -> SocialVote { vote(value ?? false) }

        // MARK: Identity

        static func id(_ value: String) -> String { value }
        static func id(_ value: UUID) -> String { value.uuidString }
        static func id<Value: CustomStringConvertible>(_ value: Value) -> String { value.description }
        static func id<Value: CustomStringConvertible>(_ value: Value?) -> String { value?.description ?? "" }
    }
    """##
}
