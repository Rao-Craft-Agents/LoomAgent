//  WHAT: The template of `SocialKeywordFilter.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialKeywordFilter = ##"""
    import Foundation

    /// A word that hides posts and comments that contain it, in the places the person chose: Loom's keyword filter.
    struct SocialKeywordFilter: Identifiable, Hashable, Codable, Sendable {
        /// Where a keyword is looked for.
        enum Field: String, CaseIterable, Hashable, Codable, Sendable {
            case title, body, link, community, author
        }

        var id = UUID()
        var keyword: String
        var fields: Set<Field> = Set(Field.allCases)

        /// Whether `post` holds the keyword in one of the chosen places, any case.
        func matches<Post: PostRepresentable>(_ post: Post) -> Bool {
            let needle = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !needle.isEmpty else { return false }
            func holds(_ text: String?) -> Bool { text?.localizedCaseInsensitiveContains(needle) ?? false }
            return (fields.contains(.title) && holds(post.socialTitle))
                || (fields.contains(.body) && holds(post.socialBody))
                || (fields.contains(.link) && holds(post.socialURL?.absoluteString))
                || (fields.contains(.community) && holds(post.socialCommunityName))
                || (fields.contains(.author) && holds(post.socialAuthorName))
        }

        /// Whether `comment` holds the keyword in its text or its author, any case.
        func matches<Comment: CommentRepresentable>(_ comment: Comment) -> Bool {
            let needle = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !needle.isEmpty else { return false }
            return (fields.contains(.body) && comment.socialText.localizedCaseInsensitiveContains(needle))
                || (fields.contains(.author) && comment.socialAuthorName.localizedCaseInsensitiveContains(needle))
        }
    }

    extension Array where Element == SocialKeywordFilter {
        /// `posts` without the ones any filter matches.
        func keeping<Post: PostRepresentable>(_ posts: [Post]) -> [Post] {
            posts.filter { post in !contains { $0.matches(post) } }
        }

        /// `comments` without the ones any filter matches.
        func keeping<Comment: CommentRepresentable>(_ comments: [Comment]) -> [Comment] {
            comments.filter { comment in !contains { $0.matches(comment) } }
        }
    }
    """##
}
