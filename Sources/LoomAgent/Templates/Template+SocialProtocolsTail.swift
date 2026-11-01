//  WHAT: The template of `SocialProtocolsTail.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialProtocolsTail = ##"""

    /// How the person using the app voted.
    enum SocialVote: Int, Hashable, Sendable {
        case down = -1
        case none = 0
        case up = 1

        /// The vote a tap on `arrow` makes: the same arrow again takes the vote back.
        func tapping(_ arrow: SocialVote) -> SocialVote { self == arrow ? .none : arrow }
    }

    /// What a control points at, as the app's own value: a post, a comment, a person, a community or an instance.
    enum SocialTarget<Social: SocialSchema> {
        case post(Social.Post)
        case comment(Social.Comment)
        case user(Social.User)
        case community(Social.Community)
        case instance(Social.Instance)

        /// What a card shows of a post or a comment, read once; nil for anything else.
        var content: SocialContentInfo? {
            switch self {
            case .post(let post): return SocialContentInfo(post)
            case .comment(let comment): return SocialContentInfo(comment)
            case .user, .community, .instance: return nil
            }
        }
    }

    /// What a card shows of a post or a comment, read once from either, so a header, a footer and a menu share it.
    struct SocialContentInfo: Sendable {
        var isComment: Bool
        var authorName: String
        var authorHandle: String?
        var authorAvatar: URL?
        var communityName: String?
        var communityIcon: URL?
        var created: Date?
        var isEdited: Bool
        var score: Int
        var upvotes: Int?
        var downvotes: Int?
        var myVote: SocialVote
        /// Comments under a post, replies under a comment.
        var replies: Int
        var isSaved: Bool
        var isNSFW: Bool
        var isPinned: Bool
        var isLocked: Bool
        var isRemoved: Bool
        var isDeleted: Bool
        var authorIsBot: Bool
        var authorIsAdmin: Bool
        var authorIsOriginalPoster: Bool
        var isMine: Bool
        var permalink: URL?
        var source: String?

        init<Post: PostRepresentable>(_ post: Post) {
            isComment = false
            authorName = post.socialAuthorName
            authorHandle = post.socialAuthorHandle
            authorAvatar = post.socialAuthorAvatar
            communityName = post.socialCommunityName
            communityIcon = post.socialCommunityIcon
            created = post.socialCreated
            isEdited = post.socialIsEdited
            score = post.socialScore
            upvotes = post.socialUpvotes
            downvotes = post.socialDownvotes
            myVote = post.socialMyVote
            replies = post.socialCommentCount
            isSaved = post.socialIsSaved
            isNSFW = post.socialIsNSFW
            isPinned = post.socialIsPinned
            isLocked = post.socialIsLocked
            isRemoved = post.socialIsRemoved
            isDeleted = post.socialIsDeleted
            authorIsBot = post.socialAuthorIsBot
            authorIsAdmin = post.socialAuthorIsAdmin
            authorIsOriginalPoster = false
            isMine = post.socialIsMine
            permalink = post.socialPermalink
            source = post.socialSource
        }

        init<Comment: CommentRepresentable>(_ comment: Comment) {
            isComment = true
            authorName = comment.socialAuthorName
            authorHandle = comment.socialAuthorHandle
            authorAvatar = comment.socialAuthorAvatar
            communityName = comment.socialCommunityName
            communityIcon = nil
            created = comment.socialCreated
            isEdited = comment.socialIsEdited
            score = comment.socialScore
            upvotes = comment.socialUpvotes
            downvotes = comment.socialDownvotes
            myVote = comment.socialMyVote
            replies = comment.socialReplyCount
            isSaved = comment.socialIsSaved
            isNSFW = false
            isPinned = false
            isLocked = false
            isRemoved = comment.socialIsRemoved
            isDeleted = comment.socialIsDeleted
            authorIsBot = comment.socialAuthorIsBot
            authorIsAdmin = comment.socialAuthorIsAdmin
            authorIsOriginalPoster = comment.socialAuthorIsOP
            isMine = comment.socialIsMine
            permalink = comment.socialPermalink
            source = nil
        }
    }

    /// Stands in for posts in an app that has none: no value of it is ever made.
    enum SocialNoPost: PostRepresentable { var id: Never { switch self {} } }

    /// Stands in for comments in an app that has none.
    enum SocialNoComment: CommentRepresentable { var id: Never { switch self {} } }

    /// Stands in for people in an app that shows none.
    enum SocialNoUser: UserRepresentable { var id: Never { switch self {} } }

    /// Stands in for communities in an app that has none, as a timeline has none.
    enum SocialNoCommunity: CommunityRepresentable { var id: Never { switch self {} } }

    /// Stands in for instances in an app that connects to one server.
    enum SocialNoInstance: InstanceRepresentable { var id: Never { switch self {} } }
    """##
}
