import Foundation

/// The apps the build test writes the kit into: a Lemmy-like one (nested counts, zone-less ISO strings for dates,
/// strings for links) and a Mastodon-like one (camelCase, `Date` and `URL`, one `Status` as a post and a reply), each
/// with sample values of its own types and a program that draws every screen from them.
enum SocialApps {
    /// A Lemmy-like API's types, mapped by `lemmyLines`.
    static let lemmyModels = #"""
        import Foundation

        // A Lemmy-like API's types: nested counts, ISO strings without a zone for dates, strings for links.
        public struct LemmyPerson: Codable, Hashable, Sendable {
            public var id: Int
            public var name: String
            public var display_name: String?
            public var avatar: String?
            public var banner: String?
            public var bio: String?
            public var actor_id: String
            public var bot_account: Bool
            public var admin: Bool?
            public var published: String
        }

        public struct LemmyCommunity: Codable, Hashable, Sendable {
            public var id: Int
            public var name: String
            public var title: String
            public var icon: String?
            public var banner: String?
            public var description: String?
            public var actor_id: String
            public var nsfw: Bool
        }

        public struct LemmyPostRecord: Codable, Hashable, Sendable {
            public var id: Int
            public var name: String
            public var body: String?
            public var url: String?
            public var thumbnail_url: String?
            public var embed_title: String?
            public var nsfw: Bool
            public var published: String
            public var updated: String?
            public var featured_community: Bool
            public var locked: Bool
            public var removed: Bool
            public var deleted: Bool
            public var ap_id: String
        }

        public struct LemmyPostCounts: Codable, Hashable, Sendable {
            public var score: Int64
            public var upvotes: Int64
            public var downvotes: Int64
            public var comments: Int64
        }

        public struct LemmyPostView: Codable, Hashable, Sendable {
            public var post: LemmyPostRecord
            public var creator: LemmyPerson
            public var community: LemmyCommunity
            public var counts: LemmyPostCounts
            public var my_vote: Int?
            public var saved: Bool
        }

        public struct LemmyCommentRecord: Codable, Hashable, Sendable {
            public var id: Int
            public var content: String
            public var path: String
            public var published: String
            public var updated: String?
            public var removed: Bool
            public var deleted: Bool
            public var ap_id: String
        }

        public struct LemmyCommentCounts: Codable, Hashable, Sendable {
            public var score: Int64
            public var upvotes: Int64
            public var downvotes: Int64
            public var child_count: Int32
        }

        public struct LemmyCommentView: Codable, Hashable, Sendable {
            public var comment: LemmyCommentRecord
            public var creator: LemmyPerson
            public var post: LemmyPostRecord
            public var community: LemmyCommunity
            public var counts: LemmyCommentCounts
            public var creator_is_op: Bool
            public var my_vote: Int?
            public var saved: Bool
        }

        public struct LemmyPersonCounts: Codable, Hashable, Sendable {
            public var post_count: Int64
            public var comment_count: Int64
        }

        public struct LemmyPersonView: Codable, Hashable, Sendable {
            public var person: LemmyPerson
            public var counts: LemmyPersonCounts
        }

        public struct LemmyCommunityCounts: Codable, Hashable, Sendable {
            public var subscribers: Int64
            public var posts: Int64
            public var comments: Int64
            public var users_active_day: Int64
            public var users_active_week: Int64
            public var users_active_month: Int64
        }

        public struct LemmyCommunityView: Codable, Hashable, Sendable {
            public var community: LemmyCommunity
            public var counts: LemmyCommunityCounts
            public var subscribed: String
            public var blocked: Bool
        }

        public struct LemmyInstance: Codable, Hashable, Sendable {
            public var id: Int
            public var domain: String
            public var software: String?
            public var version: String?
            public var published: String
        }
        """#

    static let lemmyLines = [
        #"post: LemmyPostView id=post.id title=post.name body=post.body author=creator.name handle=URL(string: value.creator.actor_id)?.host() avatar=creator.avatar community=community.name communityIcon=community.icon created=post.published edited=post.updated score=counts.score upvotes=counts.upvotes downvotes=counts.downvotes vote=my_vote comments=counts.comments url=post.url linkTitle=post.embed_title thumbnail=post.thumbnail_url nsfw=post.nsfw saved=saved pinned=post.featured_community locked=post.locked removed=post.removed deleted=post.deleted bot=creator.bot_account admin=creator.admin permalink=post.ap_id"#,
        #"comment: LemmyCommentView id=comment.id body=comment.content author=creator.name avatar=creator.avatar created=comment.published edited=comment.updated score=counts.score upvotes=counts.upvotes downvotes=counts.downvotes vote=my_vote replies=counts.child_count depth=value.comment.path.split(separator: ".").count - 2 parent=value.comment.path.split(separator: ".").dropLast().last.map(String.init) op=creator_is_op post=post.name removed=comment.removed deleted=comment.deleted saved=saved permalink=comment.ap_id"#,
        #"user: LemmyPersonView id=person.id name=person.name display=person.display_name handle=URL(string: value.person.actor_id)?.host() avatar=person.avatar banner=person.banner bio=person.bio joined=person.published posts=counts.post_count comments=counts.comment_count bot=person.bot_account admin=person.admin"#,
        #"community: LemmyCommunityView id=community.id name=community.name title=community.title handle=URL(string: value.community.actor_id)?.host() icon=community.icon banner=community.banner about=community.description subscribers=counts.subscribers posts=counts.posts comments=counts.comments activeDay=counts.users_active_day activeWeek=counts.users_active_week activeMonth=counts.users_active_month subscribed=value.subscribed == "Subscribed" nsfw=community.nsfw blocked=blocked"#,
        #"instance: LemmyInstance id=id name=domain domain=domain version=version source=software created=published"#,
    ]

    static let lemmySamples = #"""
        import Foundation

        // Sample values of the Lemmy-like types, as the API would send them.
        enum LemmySamples {
            static let ann = LemmyPerson(id: 1, name: "ann", display_name: "Ann Lee", avatar: nil, banner: nil, bio: "I bake on weekends.",
                                         actor_id: "https://bread.town/u/ann", bot_account: false, admin: false, published: "2023-01-02T10:00:00.000000")
            static let ben = LemmyPerson(id: 2, name: "ben", display_name: nil, avatar: nil, banner: nil, bio: nil,
                                         actor_id: "https://lemmy.example/u/ben", bot_account: false, admin: true, published: "2022-06-01T08:00:00")
            static let bot = LemmyPerson(id: 3, name: "digest_bot", display_name: nil, avatar: nil, banner: nil, bio: nil,
                                         actor_id: "https://lemmy.example/u/digest_bot", bot_account: true, admin: nil, published: "2023-03-03T08:00:00")
            static let baking = LemmyCommunity(id: 10, name: "baking", title: "Bread & Baking", icon: nil, banner: nil,
                                               description: "Loaves, crumbs and starters.\n\n- Be kind\n- Show your crumb", actor_id: "https://bread.town/c/baking", nsfw: false)

            static func post(_ id: Int, _ title: String, body: String? = nil, url: String? = nil, thumbnail: String? = nil, by creator: LemmyPerson = ann,
                             score: Int64 = 42, comments: Int64 = 7, nsfw: Bool = false, removed: Bool = false, vote: Int? = nil, pinned: Bool = false) -> LemmyPostView {
                LemmyPostView(post: LemmyPostRecord(id: id, name: title, body: body, url: url, thumbnail_url: thumbnail, embed_title: url == nil ? nil : "A page about \(title.lowercased())",
                                                    nsfw: nsfw, published: "2026-10-31T09:30:00.123456", updated: id == 2 ? "2026-10-31T10:00:00" : nil,
                                                    featured_community: pinned, locked: pinned, removed: removed, deleted: false, ap_id: "https://bread.town/post/\(id)"),
                              creator: creator, community: baking, counts: LemmyPostCounts(score: score, upvotes: score + 3, downvotes: 3, comments: comments),
                              my_vote: vote, saved: id == 2)
            }

            static let posts: [LemmyPostView] = [
                post(1, "What did everyone bake this weekend?", body: "I finally got an open crumb on my sourdough after three months of trying. The trick was a wetter dough and a longer cold proof. Show me yours, and tell me what flour you use!", score: 128, comments: 24, vote: 1),
                post(2, "The science of steam in home ovens", url: "https://example.com/steam", thumbnail: "https://example.com/steam.jpg", by: ben, score: 342, comments: 57, pinned: true),
                post(3, "Weekly digest", body: "Ten threads you missed.", by: bot, score: 3, comments: 0),
                post(4, "Rye that did not rise", body: "Spoiler: it was the starter.", score: 12, comments: 1, nsfw: true),
                post(5, "This was removed", body: "Gone.", score: 0, comments: 0, removed: true),
            ]

            static func comment(_ id: Int, _ content: String, path: String, by creator: LemmyPerson, replies: Int32 = 0, op: Bool = false) -> LemmyCommentView {
                LemmyCommentView(comment: LemmyCommentRecord(id: id, content: content, path: path, published: "2026-10-31T11:00:00", updated: nil,
                                                             removed: false, deleted: false, ap_id: "https://bread.town/comment/\(id)"),
                                 creator: creator, post: posts[0].post, community: baking,
                                 counts: LemmyCommentCounts(score: 9, upvotes: 10, downvotes: 1, child_count: replies), creator_is_op: op, my_vote: nil, saved: false)
            }

            static let comments: [LemmyCommentView] = [
                comment(100, "Beautiful crumb! What hydration was that?", path: "0.100", by: ben, replies: 2),
                comment(101, "About **78%**, with a 14 hour cold proof.", path: "0.100.101", by: ann, replies: 1, op: true),
                comment(102, "> 14 hour cold proof\n\nThat is the secret every time.", path: "0.100.101.102", by: bot),
                comment(103, "I use a mix of bread flour and 10% whole wheat.", path: "0.103", by: ann, op: true),
            ]

            static let people = [LemmyPersonView(person: ann, counts: LemmyPersonCounts(post_count: 48, comment_count: 301))]
            static let communities = [LemmyCommunityView(community: baking, counts: LemmyCommunityCounts(subscribers: 7_250, posts: 980, comments: 11_300, users_active_day: 120, users_active_week: 900, users_active_month: 2_400), subscribed: "Subscribed", blocked: false)]
            static let instances = [LemmyInstance(id: 1, domain: "bread.town", software: "lemmy", version: "0.19.3", published: "2023-01-01T00:00:00")]
        }
        """#

    /// Every screen, from the Lemmy-like values, in each look, light and dark.
    static let lemmyCheck = #"""
        import SwiftUI
        import ImageIO
        import UniformTypeIdentifiers

        /// Every screen of the kit, made from this app's own values and drawn offscreen: what proves nothing traps, and
        /// pictures to compare with Loom when a folder is given.
        public enum LemmyCheck {
            @MainActor
            public static func run(into folder: URL?) -> (drawn: [String], failed: [String]) {
                var drawn: [String] = [], failed: [String] = []
                var actions = SocialActions<AppSocial>()
                actions.vote = { _, _ in }
                actions.save = { _ in }
                actions.share = { _ in }
                actions.reply = { _ in }
                actions.report = { _ in }
                actions.sendReport = { _, _ in }
                actions.block = { _ in }
                actions.edit = { _ in }
                actions.delete = { _ in }
                actions.openPost = { _ in }
                actions.openUser = { _ in }
                actions.openCommunity = { _ in }
                actions.openLink = { _ in }
                actions.loadMore = {}
                actions.refresh = {}
                actions.submit = { _ in }
                actions.search = { _, _ in }
                actions.subscribe = { _ in }
                actions.connect = { _ in }
                actions.favorite = { _ in }

                func draw<Content: View>(_ name: String, width: CGFloat = 390, styles: [SocialStyle] = [.loom], dark: Bool = false,
                                         @ViewBuilder _ content: () -> Content) {
                    for style in styles {
                        for scheme in dark ? [ColorScheme.light, .dark] : [.light] {
                            let view = content()
                                .frame(width: width)
                                .fixedSize(horizontal: false, vertical: true)
                                .background(style.palette.background)
                                .socialStyle(style)
                                .environment(\.colorScheme, scheme)
                            let renderer = ImageRenderer(content: view)
                            renderer.scale = 2
                            guard let image = renderer.cgImage else { failed.append(name); continue }
                            let file = "\(name)-\(style.rawValue)-\(scheme == .dark ? "dark" : "light")"
                            drawn.append(file)
                            if let folder {
                                let url = folder.appendingPathComponent(file + ".png")
                                if let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
                                    CGImageDestinationAddImage(destination, image, nil)
                                    CGImageDestinationFinalize(destination)
                                }
                            }
                        }
                    }
                }

                let posts = LemmySamples.posts
                let comments = LemmySamples.comments
                draw("feed", styles: SocialStyle.allCases, dark: true) {
                    VStack(spacing: 0) {
                        FeedHeaderView(title: Text("Front Page"), subtitle: Text(verbatim: "bread.town"), phase: .idle)
                        Divider()
                        ForEach(posts) { post in
                            PostCardView(post: post, actions: actions)
                            Divider()
                        }
                    }
                }
                draw("thread", styles: SocialStyle.allCases, dark: true) {
                    CommentThreadView(comments: comments, phase: .exhausted, actions: actions)
                }
                draw("share", styles: SocialStyle.allCases) {
                    if let post = posts.first { PostCardView(post: post, actions: actions).socialContext(.share) }
                }
                if let post = posts.first {
                    draw("feed-view") { FeedView(title: Text("Front Page"), posts: posts, phase: .idle, actions: actions) }
                    draw("feed-empty") { FeedView(title: Text("Front Page"), posts: [AppSocial.Post](), phase: .failed("The server did not answer."), actions: actions) }
                    draw("post-page") { PostPageView(post: post, comments: comments, phase: .exhausted, actions: actions) }
                    draw("reply") { ReplyView(target: .post(post), actions: actions).frame(height: 500) }
                    draw("share-image") { ShareImageView(target: .post(post), actions: actions).frame(height: 600) }
                    draw("report") { ReportView(target: .post(post), actions: actions) }
                    draw("split", width: 1200) {
                        FeedSplitView(selection: .constant(post.id), actions: actions) {
                            Text("Sidebar")
                        } feed: { actions in
                            FeedView(title: Text("Front Page"), posts: posts, phase: .idle, actions: actions)
                        } detail: { _ in
                            PostPageView(post: post, comments: comments, actions: actions)
                        }
                        .frame(height: 700)
                    }
                }
                draw("compose") { ComposeView(communities: LemmySamples.communities, actions: actions).frame(height: 500) }
                if let user = LemmySamples.people.first {
                    draw("profile-header", dark: true) { UserProfileHeaderView(user: user, actions: actions) }
                    draw("profile") { ProfileView(user: user, posts: posts, comments: comments, phase: .exhausted, actions: actions) }
                    draw("user-card") { UserCardView(user: user, actions: actions, showsCounts: true).padding() }
                }
                if let community = LemmySamples.communities.first {
                    draw("community-card", dark: true) { CommunityCardView(community: community, actions: actions).padding() }
                    draw("community-sidebar") { CommunitySidebarView(community: community, actions: actions) }
                }
                draw("community-picker") { CommunityPickerView(communities: LemmySamples.communities, phase: .exhausted, actions: actions) }
                draw("search") {
                    SearchView(query: .constant("bread"), scope: .constant(.all), posts: posts, comments: comments,
                               users: LemmySamples.people, communities: LemmySamples.communities, phase: .exhausted, actions: actions)
                        .frame(height: 800)
                }
                if let instance = LemmySamples.instances.first {
                    draw("instance", dark: true) { InstanceCardView(instance: instance, actions: actions).padding() }
                }
                draw("filter") { KeywordFilterView(filters: .constant([SocialKeywordFilter(keyword: "spoilers")])).padding() }
                return (drawn, failed)
            }
        }
        """#

    /// A Mastodon-like API's types, mapped by `mastodonLines`: no communities, so `AppSocial` stands one in.
    static let mastodonModels = #"""
        import Foundation

        // A Mastodon-like API's types: camelCase, real Dates and URLs, flat counts, and one Status for a post and a reply.
        public struct MastodonAccount: Codable, Hashable, Identifiable {
            public var id: String
            public var username: String
            public var acct: String
            public var displayName: String
            public var avatar: URL
            public var header: URL?
            public var note: String
            public var createdAt: Date
            public var followersCount: Int
            public var followingCount: Int
            public var statusesCount: Int
            public var bot: Bool
            public var url: URL
        }

        public struct MastodonAttachment: Codable, Hashable {
            public var id: String
            public var url: URL
            public var previewURL: URL?
        }

        public struct MastodonCard: Codable, Hashable {
            public var url: URL
            public var title: String
            public var image: URL?
        }

        public struct MastodonStatus: Codable, Hashable, Identifiable {
            public var id: String
            public var content: String
            public var account: MastodonAccount
            public var createdAt: Date
            public var editedAt: Date?
            public var favouritesCount: Int
            public var reblogsCount: Int
            public var repliesCount: Int
            public var favourited: Bool?
            public var bookmarked: Bool?
            public var sensitive: Bool
            public var mediaAttachments: [MastodonAttachment]
            public var url: URL?
            public var inReplyToId: String?
            public var card: MastodonCard?
        }

        public struct MastodonInstanceStats: Codable, Hashable {
            public var userCount: Int
            public var statusCount: Int
        }

        public struct MastodonInstance: Codable, Hashable {
            public var uri: String
            public var title: String
            public var description: String
            public var thumbnail: URL?
            public var version: String
            public var stats: MastodonInstanceStats
        }
        """#

    static let mastodonLines = [
        #"post: MastodonStatus body=content author=account.displayName handle=account.acct avatar=account.avatar created=createdAt edited=editedAt score=favouritesCount vote=favourited comments=repliesCount url=value.card?.url linkTitle=value.card?.title thumbnail=value.card?.image media=value.mediaAttachments.map(\.url) nsfw=sensitive saved=bookmarked bot=account.bot permalink=url"#,
        #"comment: MastodonStatus body=content author=account.displayName handle=account.acct avatar=account.avatar created=createdAt edited=editedAt score=favouritesCount vote=favourited replies=repliesCount parent=inReplyToId saved=bookmarked bot=account.bot permalink=url"#,
        #"user: MastodonAccount name=username display=displayName handle=acct avatar=avatar banner=header bio=note joined=createdAt posts=statusesCount followers=followersCount following=followingCount bot=bot permalink=url"#,
        #"instance: MastodonInstance id=uri name=title domain=uri icon=thumbnail about=description users=stats.userCount posts=stats.statusCount version=version"#,
    ]

    static let mastodonSamples = #"""
        import Foundation

        // Sample values of the Mastodon-like types.
        enum MastodonSamples {
            static let account = MastodonAccount(id: "a1", username: "cleo", acct: "cleo@kitchen.social", displayName: "Cleo", avatar: URL(fileURLWithPath: "/avatar.png"),
                                                 header: nil, note: "Soups and stews.", createdAt: Date(timeIntervalSince1970: 1_700_000_000), followersCount: 830,
                                                 followingCount: 120, statusesCount: 212, bot: false, url: URL(fileURLWithPath: "/@cleo"))

            static func status(_ id: String, _ content: String, replyTo: String? = nil, media: Int = 0, card: Bool = false) -> MastodonStatus {
                MastodonStatus(id: id, content: content, account: account, createdAt: Date.now.addingTimeInterval(-3_600), editedAt: nil,
                               favouritesCount: 14, reblogsCount: 2, repliesCount: replyTo == nil ? 3 : 0, favourited: true, bookmarked: false,
                               sensitive: false, mediaAttachments: (0..<media).map { MastodonAttachment(id: "m\($0)", url: URL(fileURLWithPath: "/m\($0).jpg"), previewURL: nil) },
                               url: URL(fileURLWithPath: "/statuses/\(id)"), inReplyToId: replyTo,
                               card: card ? MastodonCard(url: URL(fileURLWithPath: "/recipe"), title: "Winter soup", image: nil) : nil)
            }

            static let statuses = [status("s1", "Made a big pot of lentil soup today."), status("s2", "Look at this loaf", media: 2), status("s3", "Recipe in the link", card: true)]
            static let replies = [status("r1", "Looks great!", replyTo: "s1"), status("r2", "Thank you!", replyTo: "r1")]
            static let instance = MastodonInstance(uri: "kitchen.social", title: "Kitchen Social", description: "For people who cook.", thumbnail: nil,
                                                   version: "4.2.0", stats: MastodonInstanceStats(userCount: 12_000, statusCount: 400_000))
        }
        """#

    /// Every screen, from the Mastodon-like values.
    static let mastodonCheck = #"""
        import SwiftUI
        import ImageIO
        import UniformTypeIdentifiers

        /// Every screen of the kit, made from this app's own values and drawn offscreen: what proves nothing traps, and
        /// pictures to compare with Loom when a folder is given.
        public enum MastodonCheck {
            @MainActor
            public static func run(into folder: URL?) -> (drawn: [String], failed: [String]) {
                var drawn: [String] = [], failed: [String] = []
                var actions = SocialActions<AppSocial>()
                actions.vote = { _, _ in }
                actions.save = { _ in }
                actions.share = { _ in }
                actions.reply = { _ in }
                actions.report = { _ in }
                actions.sendReport = { _, _ in }
                actions.block = { _ in }
                actions.edit = { _ in }
                actions.delete = { _ in }
                actions.openPost = { _ in }
                actions.openUser = { _ in }
                actions.openCommunity = { _ in }
                actions.openLink = { _ in }
                actions.loadMore = {}
                actions.refresh = {}
                actions.submit = { _ in }
                actions.search = { _, _ in }
                actions.subscribe = { _ in }
                actions.connect = { _ in }
                actions.favorite = { _ in }

                func draw<Content: View>(_ name: String, width: CGFloat = 390, styles: [SocialStyle] = [.loom], dark: Bool = false,
                                         @ViewBuilder _ content: () -> Content) {
                    for style in styles {
                        for scheme in dark ? [ColorScheme.light, .dark] : [.light] {
                            let view = content()
                                .frame(width: width)
                                .fixedSize(horizontal: false, vertical: true)
                                .background(style.palette.background)
                                .socialStyle(style)
                                .environment(\.colorScheme, scheme)
                            let renderer = ImageRenderer(content: view)
                            renderer.scale = 2
                            guard let image = renderer.cgImage else { failed.append(name); continue }
                            let file = "\(name)-\(style.rawValue)-\(scheme == .dark ? "dark" : "light")"
                            drawn.append(file)
                            if let folder {
                                let url = folder.appendingPathComponent(file + ".png")
                                if let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
                                    CGImageDestinationAddImage(destination, image, nil)
                                    CGImageDestinationFinalize(destination)
                                }
                            }
                        }
                    }
                }

                let posts = MastodonSamples.statuses
                let comments = MastodonSamples.replies
                draw("feed", styles: SocialStyle.allCases, dark: true) {
                    VStack(spacing: 0) {
                        FeedHeaderView(title: Text("Front Page"), subtitle: Text(verbatim: "bread.town"), phase: .idle)
                        Divider()
                        ForEach(posts) { post in
                            PostCardView(post: post, actions: actions)
                            Divider()
                        }
                    }
                }
                draw("thread", styles: SocialStyle.allCases, dark: true) {
                    CommentThreadView(comments: comments, phase: .exhausted, actions: actions)
                }
                draw("share", styles: SocialStyle.allCases) {
                    if let post = posts.first { PostCardView(post: post, actions: actions).socialContext(.share) }
                }
                if let post = posts.first {
                    draw("feed-view") { FeedView(title: Text("Front Page"), posts: posts, phase: .idle, actions: actions) }
                    draw("feed-empty") { FeedView(title: Text("Front Page"), posts: [AppSocial.Post](), phase: .failed("The server did not answer."), actions: actions) }
                    draw("post-page") { PostPageView(post: post, comments: comments, phase: .exhausted, actions: actions) }
                    draw("reply") { ReplyView(target: .post(post), actions: actions).frame(height: 500) }
                    draw("share-image") { ShareImageView(target: .post(post), actions: actions).frame(height: 600) }
                    draw("report") { ReportView(target: .post(post), actions: actions) }
                    draw("split", width: 1200) {
                        FeedSplitView(selection: .constant(post.id), actions: actions) {
                            Text("Sidebar")
                        } feed: { actions in
                            FeedView(title: Text("Front Page"), posts: posts, phase: .idle, actions: actions)
                        } detail: { _ in
                            PostPageView(post: post, comments: comments, actions: actions)
                        }
                        .frame(height: 700)
                    }
                }
                draw("compose") { ComposeView<AppSocial>(actions: actions).frame(height: 500) }
                if let user = Optional(MastodonSamples.account) {
                    draw("profile-header", dark: true) { UserProfileHeaderView(user: user, actions: actions) }
                    draw("profile") { ProfileView(user: user, posts: posts, comments: comments, phase: .exhausted, actions: actions) }
                    draw("user-card") { UserCardView(user: user, actions: actions, showsCounts: true).padding() }
                }
                draw("search") {
                    SearchView(query: .constant("bread"), scope: .constant(.all), posts: posts, comments: comments,
                               users: [MastodonSamples.account], communities: [AppSocial.Community](), phase: .exhausted, actions: actions)
                        .frame(height: 800)
                }
                if let instance = Optional(MastodonSamples.instance) {
                    draw("instance", dark: true) { InstanceCardView(instance: instance, actions: actions).padding() }
                }
                draw("filter") { KeywordFilterView(filters: .constant([SocialKeywordFilter(keyword: "spoilers")])).padding() }
                return (drawn, failed)
            }
        }
        """#

    /// The screens of the least call, from the Lemmy-like values: `__APP__` names the app.
    static let leastCheck = #"""
        import SwiftUI

        /// The least a call can ask for (no features, four screens, the reader look, colours from assets, a prefix), drawn
        /// from the app's own values.
        public enum __APP__Check {
            @MainActor
            public static func run() -> (drawn: [String], failed: [String]) {
                var drawn: [String] = [], failed: [String] = []
                var actions = SocialActions<AppSocial>()
                actions.openPost = { _ in }
                actions.openUser = { _ in }
                actions.openCommunity = { _ in }
                actions.openLink = { _ in }
                actions.loadMore = {}
                actions.refresh = {}

                func draw<Content: View>(_ name: String, @ViewBuilder _ content: () -> Content) {
                    for style in SocialStyle.allCases {
                        let view = content().frame(width: 390).fixedSize(horizontal: false, vertical: true).socialStyle(style)
                        if ImageRenderer(content: view).cgImage == nil { failed.append(name) } else { drawn.append(name) }
                    }
                }

                let posts = LemmySamples.posts
                let comments = LemmySamples.comments
                draw("cards") { VStack(spacing: 0) { ForEach(posts) { KitPostCardView(post: $0, actions: actions) } } }
                draw("thread") { KitCommentThreadView(comments: comments, phase: .exhausted, actions: actions) }
                draw("feed") { KitFeedView(title: Text("Front Page"), posts: posts, phase: .idle, actions: actions) }
                if let post = posts.first {
                    draw("page") { KitPostPageView(post: post, comments: comments, phase: .exhausted, actions: actions) }
                }
                if let user = LemmySamples.people.first {
                    draw("profile") { KitProfileView(user: user, posts: posts, comments: comments, phase: .exhausted, actions: actions) }
                }
                return (drawn, failed)
            }
        }
        """#
}
