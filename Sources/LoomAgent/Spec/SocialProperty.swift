//  WHAT: One thing a social view reads off an app's type: the word a mapping line names it by, the requirement it
//        is in the protocol, what it holds, and the sentence that documents it.

import Foundation

struct SocialProperty: Sendable, Equatable {
    /// The word on a mapping line: `title`, `avatar`, `comments`.
    let key: String
    /// The protocol requirement: `socialTitle`. Namespaced, so an app's own `title` never collides with it.
    let member: String
    let kind: SocialKind
    /// One sentence, the requirement's doc comment.
    let doc: String
    /// Other words a line may use for it.
    let aliases: [String]

    init(_ key: String, _ member: String, _ kind: SocialKind, _ doc: String, aliases: [String] = []) {
        self.key = key; self.member = member; self.kind = kind; self.doc = doc; self.aliases = aliases
    }
}
