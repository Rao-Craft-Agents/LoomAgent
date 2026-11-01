//  WHAT: The five roles an app's type can take for the social views (a post, a comment, a user, a community, an
//        instance) and everything each role's views read. The one source of the protocols written into the app,
//        of what a mapping line may name, and of the guide's word list.
//  PIN:  ONE TABLE. The protocol file, the conformances and the tests all read these lists, so a property added
//        here is a requirement, a mapping word and a default at once.

import Foundation

enum SocialRole: String, CaseIterable, Sendable {
    case post, comment, user, community, instance

    /// The protocol an app's type conforms to: `PostRepresentable`.
    var protocolName: String { name + "Representable" }

    /// The role's name in Swift: `Post`, the schema's associated type.
    var name: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    /// The type that stands in when an app has no such thing (a timeline has no communities).
    var absentType: String { "SocialNo" + name }

    /// Other words a mapping line may start with.
    var aliases: [String] {
        switch self {
        case .post: return ["status", "story", "item", "entry", "article"]
        case .comment: return ["reply", "note"]
        case .user: return ["person", "account", "author", "profile", "member"]
        case .community: return ["group", "forum", "board", "channel", "subreddit", "magazine"]
        case .instance: return ["server", "site", "host"]
        }
    }

    /// What the role is, for the protocol's doc comment.
    var doc: String {
        switch self {
        case .post: return "A post as the social views show it: a card in a feed, the head of its page."
        case .comment: return "A comment as the social views show it: a card in a thread, nested under its parent."
        case .user: return "A person as the social views show them: an avatar, a card, a profile header."
        case .community: return "A community as the social views show it: a card, a picker row, a sidebar."
        case .instance: return "A server of a federated network as the social views show it: a card to connect to."
        }
    }

    var properties: [SocialProperty] {
        switch self {
        case .post:
            return [
                .init("title", "socialTitle", .text, "The headline; a post without one shows its body alone."),
                .init("body", "socialBody", .optionalText, "The text, in Markdown.", aliases: ["text", "content", "description"]),
                .init("author", "socialAuthorName", .text, "Who wrote it, as shown.", aliases: ["creator", "by", "username"]),
                .init("handle", "socialAuthorHandle", .optionalText, "Where the author is from, shown under the name: `lemmy.world`, `@ann@mastodon.social`."),
                .init("avatar", "socialAuthorAvatar", .url, "The author's picture."),
                .init("community", "socialCommunityName", .optionalText, "The community it was posted to.", aliases: ["group", "forum", "subreddit"]),
                .init("communityIcon", "socialCommunityIcon", .url, "The community's picture."),
                .init("created", "socialCreated", .date, "When it was posted.", aliases: ["published", "date", "createdAt", "posted"]),
                .init("edited", "socialIsEdited", .flag, "Whether it was changed after posting: a flag, or the date it was.", aliases: ["updated"]),
                .init("score", "socialScore", .int, "Its score: upvotes less downvotes, or likes.", aliases: ["points", "likes", "votes"]),
                .init("upvotes", "socialUpvotes", .optionalInt, "Its upvotes, when the network counts them apart from downvotes.", aliases: ["ups"]),
                .init("downvotes", "socialDownvotes", .optionalInt, "Its downvotes, when the network counts them.", aliases: ["downs"]),
                .init("vote", "socialMyVote", .vote, "How the person using the app voted: `1`, `-1`, `0`, or a liked flag.", aliases: ["myVote", "liked"]),
                .init("comments", "socialCommentCount", .int, "How many comments it has.", aliases: ["commentCount", "replies"]),
                .init("url", "socialURL", .url, "The link it shares.", aliases: ["link"]),
                .init("linkTitle", "socialLinkTitle", .optionalText, "The shared page's title, when the network sends one.", aliases: ["embedTitle"]),
                .init("thumbnail", "socialThumbnail", .url, "A small picture of what it shares.", aliases: ["image", "thumb"]),
                .init("media", "socialMedia", .urls, "Its pictures, in order: a gallery.", aliases: ["images", "attachments"]),
                .init("nsfw", "socialIsNSFW", .flag, "Whether it is marked not safe for work.", aliases: ["sensitive"]),
                .init("saved", "socialIsSaved", .flag, "Whether the person using the app saved it.", aliases: ["bookmarked"]),
                .init("pinned", "socialIsPinned", .flag, "Whether it is pinned to the top of its feed.", aliases: ["featured", "sticky"]),
                .init("locked", "socialIsLocked", .flag, "Whether it takes no more comments."),
                .init("removed", "socialIsRemoved", .flag, "Whether a moderator removed it."),
                .init("deleted", "socialIsDeleted", .flag, "Whether its author deleted it."),
                .init("bot", "socialAuthorIsBot", .flag, "Whether its author is a bot."),
                .init("admin", "socialAuthorIsAdmin", .flag, "Whether its author runs the server or the community."),
                .init("mine", "socialIsMine", .flag, "Whether the person using the app wrote it: their menu offers edit and delete, not block.", aliases: ["isMine", "own"]),
                .init("permalink", "socialPermalink", .url, "Where it lives on the web: what share, copy and open in the browser use.", aliases: ["webURL", "apID"]),
                .init("source", "socialSource", .optionalText, "Where it came from when that is worth a word beside it: `rss`, `mastodon`."),
            ]
        case .comment:
            return [
                .init("body", "socialText", .text, "The text, in Markdown.", aliases: ["text", "content"]),
                .init("author", "socialAuthorName", .text, "Who wrote it, as shown.", aliases: ["creator", "by", "username"]),
                .init("handle", "socialAuthorHandle", .optionalText, "Where the author is from, shown under the name."),
                .init("avatar", "socialAuthorAvatar", .url, "The author's picture."),
                .init("created", "socialCreated", .date, "When it was written.", aliases: ["published", "date", "createdAt"]),
                .init("edited", "socialIsEdited", .flag, "Whether it was changed after posting: a flag, or the date it was.", aliases: ["updated"]),
                .init("score", "socialScore", .int, "Its score: upvotes less downvotes, or likes.", aliases: ["points", "likes", "votes"]),
                .init("upvotes", "socialUpvotes", .optionalInt, "Its upvotes, when the network counts them apart from downvotes.", aliases: ["ups"]),
                .init("downvotes", "socialDownvotes", .optionalInt, "Its downvotes, when the network counts them.", aliases: ["downs"]),
                .init("vote", "socialMyVote", .vote, "How the person using the app voted: `1`, `-1`, `0`, or a liked flag.", aliases: ["myVote", "liked"]),
                .init("replies", "socialReplyCount", .int, "How many replies it has, all the way down.", aliases: ["replyCount", "children"]),
                .init("depth", "socialDepth", .int, "How deep it sits in its thread: 0 for a reply to the post.", aliases: ["level"]),
                .init("parent", "socialParentID", .optionalText, "The comment it answers, by id; none for a reply to the post.", aliases: ["parentID", "inReplyTo"]),
                .init("op", "socialAuthorIsOP", .flag, "Whether its author wrote the post too.", aliases: ["isOP"]),
                .init("post", "socialPostTitle", .optionalText, "The title of the post it is under, shown where the post is not.", aliases: ["postTitle"]),
                .init("community", "socialCommunityName", .optionalText, "The community of the post it is under."),
                .init("saved", "socialIsSaved", .flag, "Whether the person using the app saved it.", aliases: ["bookmarked"]),
                .init("removed", "socialIsRemoved", .flag, "Whether a moderator removed it."),
                .init("deleted", "socialIsDeleted", .flag, "Whether its author deleted it."),
                .init("bot", "socialAuthorIsBot", .flag, "Whether its author is a bot."),
                .init("admin", "socialAuthorIsAdmin", .flag, "Whether its author runs the server or the community."),
                .init("mine", "socialIsMine", .flag, "Whether the person using the app wrote it.", aliases: ["isMine", "own"]),
                .init("permalink", "socialPermalink", .url, "Where it lives on the web.", aliases: ["webURL", "apID"]),
            ]
        case .user:
            return [
                .init("name", "socialName", .text, "The name they go by: their username.", aliases: ["username", "acct"]),
                .init("display", "socialDisplayName", .optionalText, "The name they chose to show, when it differs.", aliases: ["displayName"]),
                .init("handle", "socialHandle", .optionalText, "Where they are from: `lemmy.world`, `@ann@mastodon.social`.", aliases: ["host", "domain"]),
                .init("avatar", "socialAvatar", .url, "Their picture.", aliases: ["picture", "photo"]),
                .init("banner", "socialBanner", .url, "The picture across the top of their profile.", aliases: ["header", "cover"]),
                .init("bio", "socialBio", .optionalText, "What they say about themselves, in Markdown.", aliases: ["about", "note", "description"]),
                .init("joined", "socialJoined", .date, "When they joined.", aliases: ["created", "published", "createdAt"]),
                .init("posts", "socialPostCount", .optionalInt, "How many posts they made.", aliases: ["postCount", "statuses"]),
                .init("comments", "socialCommentCount", .optionalInt, "How many comments they made.", aliases: ["commentCount"]),
                .init("score", "socialScore", .optionalInt, "Their total score.", aliases: ["karma"]),
                .init("postScore", "socialPostScore", .optionalInt, "The score of their posts."),
                .init("commentScore", "socialCommentScore", .optionalInt, "The score of their comments."),
                .init("followers", "socialFollowerCount", .optionalInt, "How many follow them.", aliases: ["followerCount"]),
                .init("following", "socialFollowingCount", .optionalInt, "How many they follow.", aliases: ["followingCount"]),
                .init("bot", "socialIsBot", .flag, "Whether they are a bot."),
                .init("admin", "socialIsAdmin", .flag, "Whether they run the server."),
                .init("blocked", "socialIsBlocked", .flag, "Whether the person using the app blocked them."),
                .init("mine", "socialIsMine", .flag, "Whether they are the person using the app.", aliases: ["isMe", "me"]),
                .init("permalink", "socialPermalink", .url, "Their profile on the web.", aliases: ["webURL", "apID"]),
            ]
        case .community:
            return [
                .init("name", "socialName", .text, "Its short name: `swift`.", aliases: ["slug"]),
                .init("title", "socialTitle", .optionalText, "The name it shows: `Swift Programming`.", aliases: ["displayName"]),
                .init("handle", "socialHandle", .optionalText, "Where it lives: `lemmy.world`.", aliases: ["host", "domain"]),
                .init("icon", "socialIcon", .url, "Its picture.", aliases: ["avatar", "image"]),
                .init("banner", "socialBanner", .url, "The picture across the top of its feed.", aliases: ["header", "cover"]),
                .init("about", "socialAbout", .optionalText, "What it is for and its rules, in Markdown.", aliases: ["description", "sidebar", "bio"]),
                .init("subscribers", "socialSubscriberCount", .optionalInt, "How many subscribe to it.", aliases: ["members", "followers"]),
                .init("posts", "socialPostCount", .optionalInt, "How many posts it holds.", aliases: ["postCount"]),
                .init("comments", "socialCommentCount", .optionalInt, "How many comments it holds.", aliases: ["commentCount"]),
                .init("activeDay", "socialActiveToday", .optionalInt, "How many people were active in it today.", aliases: ["usersActiveDay"]),
                .init("activeWeek", "socialActiveThisWeek", .optionalInt, "How many people were active in it this week.", aliases: ["usersActiveWeek"]),
                .init("activeMonth", "socialActiveThisMonth", .optionalInt, "How many people were active in it this month.", aliases: ["usersActiveMonth"]),
                .init("subscribed", "socialIsSubscribed", .flag, "Whether the person using the app subscribes to it.", aliases: ["joined", "following"]),
                .init("nsfw", "socialIsNSFW", .flag, "Whether it is marked not safe for work."),
                .init("blocked", "socialIsBlocked", .flag, "Whether the person using the app blocked it."),
                .init("permalink", "socialPermalink", .url, "Where it lives on the web.", aliases: ["webURL", "apID"]),
            ]
        case .instance:
            return [
                .init("name", "socialName", .text, "Its name: `Lemmy World`.", aliases: ["title"]),
                .init("domain", "socialDomain", .text, "Its address: `lemmy.world`.", aliases: ["host", "url"]),
                .init("icon", "socialIcon", .url, "Its picture.", aliases: ["avatar", "image"]),
                .init("banner", "socialBanner", .url, "The picture across the top of its card.", aliases: ["header", "cover"]),
                .init("about", "socialAbout", .optionalText, "What it says about itself, in Markdown.", aliases: ["description", "sidebar"]),
                .init("users", "socialUserCount", .optionalInt, "How many people use it.", aliases: ["userCount", "members"]),
                .init("posts", "socialPostCount", .optionalInt, "How many posts it holds.", aliases: ["postCount"]),
                .init("version", "socialVersion", .optionalText, "The software it runs, with its version."),
                .init("latency", "socialLatency", .number, "How long it took to answer, in seconds.", aliases: ["ping"]),
                .init("connected", "socialIsConnected", .flag, "Whether the app is connected to it.", aliases: ["current"]),
                .init("favorite", "socialIsFavorite", .flag, "Whether the person using the app starred it.", aliases: ["starred"]),
                .init("source", "socialSource", .optionalText, "The kind of server it is when that is worth a word: `lemmy`, `mastodon`, `rss`.", aliases: ["software", "kind"]),
                .init("created", "socialCreated", .date, "When it started.", aliases: ["published", "createdAt"]),
            ]
        }
    }

    /// The property a mapping line's word names, by its key or an alias, any case.
    func property(named word: String) -> SocialProperty? {
        let lower = word.lowercased()
        return properties.first { $0.key.lowercased() == lower } ?? properties.first { $0.aliases.contains { $0.lowercased() == lower } }
    }

    /// The role a mapping line's first word names, by its name or an alias, any case.
    static func named(_ word: String) -> SocialRole? {
        let lower = word.lowercased()
        return SocialRole(rawValue: lower) ?? allCases.first { $0.aliases.contains(lower) }
    }
}
