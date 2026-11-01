//  WHAT: One mapping line, read: which role an app's type takes, and how each thing the views show is read off it.

import Foundation

struct Mapping: Sendable, Equatable {
    /// How a right side reads its value.
    enum Source: Sendable, Equatable {
        /// A bare path, read off the value: `creator.name`, `counts?.score`.
        case path(String)
        /// Swift that may name `value`: `value.name ?? "Untitled"`.
        case expression(String)
    }

    struct Assignment: Sendable, Equatable {
        let property: SocialProperty
        let source: Source
    }

    let line: String
    let role: SocialRole
    /// The app's type, as the line wrote it: `Post`, `LemmyKit.PostView`.
    let type: String
    /// How the type is identified, when the line says so (`id=post.id`); nil when it has an `id` of its own.
    let id: Source?
    let assignments: [Assignment]

    /// The type's name for a file: `LemmyKit.PostView` is `LemmyKitPostView`.
    var fileStem: String { type.replacingOccurrences(of: ".", with: "") }
}
