//  WHAT: The template of `SocialPreviews.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialPreviews = ##"""
    import SwiftUI

    /// Small sample types for the social views' previews: a cooking community's posts, comments, people and places.
    /// Not the app's types, so every preview works before the app maps its own.
    enum SocialSample: SocialSchema {
        struct Post: PostRepresentable {
            var id: String
            var socialTitle: String
            var socialBody: String?
            var socialAuthorName: String
            var socialAuthorHandle: String?
            var socialAuthorAvatar: URL?
            var socialCommunityName: String?
            var socialCreated: Date?
            var socialIsEdited = false
            var socialScore: Int
            var socialUpvotes: Int?
            var socialDownvotes: Int?
            var socialMyVote: SocialVote = .none
            var socialCommentCount: Int
            var socialURL: URL?
            var socialLinkTitle: String?
            var socialThumbnail: URL?
            var socialMedia: [URL] = []
            var socialIsNSFW = false
            var socialIsSaved = false
            var socialIsPinned = false
            var socialIsLocked = false
            var socialIsMine = false
            var socialPermalink: URL?
        }

        struct Comment: CommentRepresentable {
            var id: String
            var socialText: String
            var socialAuthorName: String
            var socialAuthorHandle: String?
            var socialCreated: Date?
            var socialScore: Int
            var socialUpvotes: Int?
            var socialDownvotes: Int?
            var socialMyVote: SocialVote = .none
            var socialReplyCount: Int
            var socialDepth: Int
            var socialParentID: String?
            var socialAuthorIsOP = false
            var socialPostTitle: String?
            var socialIsMine = false
            var socialIsSaved = false
        }

        struct User: UserRepresentable {
            var id: String
            var socialName: String
            var socialDisplayName: String?
            var socialHandle: String?
            var socialBio: String?
            var socialJoined: Date?
            var socialPostCount: Int?
            var socialCommentCount: Int?
            var socialPostScore: Int?
            var socialCommentScore: Int?
            var socialFollowerCount: Int?
            var socialIsMine = false
        }

        struct Community: CommunityRepresentable {
            var id: String
            var socialName: String
            var socialTitle: String?
            var socialHandle: String?
            var socialAbout: String?
            var socialSubscriberCount: Int?
            var socialPostCount: Int?
            var socialCommentCount: Int?
            var socialActiveToday: Int?
            var socialActiveThisWeek: Int?
            var socialActiveThisMonth: Int?
            var socialIsSubscribed = false
        }

        struct Instance: InstanceRepresentable {
            var id: String
            var socialName: String
            var socialDomain: String
            var socialAbout: String?
            var socialUserCount: Int?
            var socialVersion: String?
            var socialLatency: Double?
            var socialIsConnected = false
            var socialIsFavorite = false
        }

        static let posts: [Post] = [
            Post(id: "p1", socialTitle: "What is everyone cooking this weekend?",
                 socialBody: "Trying a slow-roasted tomato soup with **basil oil**. Share what you are making, recipes welcome!",
                 socialAuthorName: "maria", socialAuthorHandle: "kitchen.social", socialCommunityName: "cooking",
                 socialCreated: Date.now.addingTimeInterval(-2_700), socialScore: 128, socialUpvotes: 140, socialDownvotes: 12,
                 socialMyVote: .up, socialCommentCount: 24, socialPermalink: URL(string: "https://kitchen.social/post/1")),
            Post(id: "p2", socialTitle: "A field guide to sourdough starters",
                 socialAuthorName: "breadhead", socialAuthorHandle: "crumb.club", socialCommunityName: "baking",
                 socialCreated: Date.now.addingTimeInterval(-86_400 * 3), socialScore: 342, socialUpvotes: 351, socialDownvotes: 9,
                 socialCommentCount: 57, socialURL: URL(string: "https://example.com/sourdough"),
                 socialLinkTitle: "Sourdough starters, explained", socialIsSaved: true, socialIsPinned: true),
            Post(id: "p3", socialTitle: "The hottest wing sauce I have ever made",
                 socialBody: "Habanero, mango and a little too much ghost pepper.",
                 socialAuthorName: "spice.rack", socialCommunityName: "cooking",
                 socialCreated: Date.now.addingTimeInterval(-600), socialScore: 12, socialUpvotes: 15, socialDownvotes: 3,
                 socialCommentCount: 1, socialIsNSFW: true),
        ]

        static let comments: [Comment] = [
            Comment(id: "c1", socialText: "Roasted garlic changes everything. Squeeze in a whole head.",
                    socialAuthorName: "lin", socialAuthorHandle: "kitchen.social", socialCreated: Date.now.addingTimeInterval(-1_800),
                    socialScore: 41, socialUpvotes: 43, socialDownvotes: 2, socialReplyCount: 2, socialDepth: 0, socialParentID: nil),
            Comment(id: "c2", socialText: "Agreed, and a splash of *balsamic* at the end.",
                    socialAuthorName: "maria", socialAuthorHandle: "kitchen.social", socialCreated: Date.now.addingTimeInterval(-1_500),
                    socialScore: 17, socialUpvotes: 17, socialDownvotes: 0, socialMyVote: .up, socialReplyCount: 1, socialDepth: 1,
                    socialParentID: "c1", socialAuthorIsOP: true),
            Comment(id: "c3", socialText: "Saving this for Sunday.",
                    socialAuthorName: "tomas", socialCreated: Date.now.addingTimeInterval(-900),
                    socialScore: 3, socialUpvotes: 3, socialDownvotes: 0, socialReplyCount: 0, socialDepth: 2, socialParentID: "c2"),
            Comment(id: "c4", socialText: "Lentil stew with smoked paprika here. Cheap, and better the next day.",
                    socialAuthorName: "ade", socialAuthorHandle: "crumb.club", socialCreated: Date.now.addingTimeInterval(-600),
                    socialScore: 9, socialUpvotes: 10, socialDownvotes: 1, socialReplyCount: 0, socialDepth: 0, socialParentID: nil,
                    socialPostTitle: "What is everyone cooking this weekend?"),
        ]

        static let users: [User] = [
            User(id: "u1", socialName: "maria", socialDisplayName: "Maria Alvarez", socialHandle: "kitchen.social",
                 socialBio: "Home cook. Soups, stews and anything slow.", socialJoined: Date.now.addingTimeInterval(-86_400 * 400),
                 socialPostCount: 212, socialCommentCount: 1_840, socialPostScore: 9_310, socialCommentScore: 12_004, socialFollowerCount: 830),
            User(id: "u2", socialName: "breadhead", socialHandle: "crumb.club", socialPostCount: 48, socialCommentCount: 301),
        ]

        static let communities: [Community] = [
            Community(id: "m1", socialName: "cooking", socialTitle: "Home Cooking", socialHandle: "kitchen.social",
                      socialAbout: "Recipes, techniques and weeknight dinners.\n\n- Be kind\n- Credit your sources",
                      socialSubscriberCount: 18_400, socialPostCount: 3_200, socialCommentCount: 41_000,
                      socialActiveToday: 320, socialActiveThisWeek: 2_100, socialActiveThisMonth: 6_800, socialIsSubscribed: true),
            Community(id: "m2", socialName: "baking", socialTitle: "Bread & Baking", socialHandle: "crumb.club",
                      socialSubscriberCount: 7_250, socialPostCount: 980, socialCommentCount: 11_300),
        ]

        static let instances: [Instance] = [
            Instance(id: "i1", socialName: "Kitchen Social", socialDomain: "kitchen.social",
                     socialAbout: "A home for people who cook.", socialUserCount: 12_000, socialVersion: "0.19.3",
                     socialLatency: 0.42, socialIsConnected: true),
            Instance(id: "i2", socialName: "Crumb Club", socialDomain: "crumb.club", socialLatency: 1.6, socialIsFavorite: true),
        ]
    }

    extension SocialActions where Social == SocialSample {
        /// Every action set to do nothing, so a preview shows every control.
        static var sample: SocialActions<SocialSample> {
            var actions = SocialActions<SocialSample>()
    //@if vote
            actions.vote = { _, _ in }
    //@endif
    //@if save
            actions.save = { _ in }
    //@endif
    //@if share
            actions.share = { _ in }
    //@endif
    //@if reply
            actions.reply = { _ in }
    //@endif
    //@if report
            actions.report = { _ in }
            actions.sendReport = { _, _ in }
    //@endif
    //@if block
            actions.block = { _ in }
    //@endif
    //@if editing
            actions.edit = { _ in }
            actions.delete = { _ in }
    //@endif
            actions.openPost = { _ in }
            actions.openUser = { _ in }
            actions.openCommunity = { _ in }
            actions.loadMore = {}
            actions.refresh = {}
    //@if part.ComposeView || part.ReplyView
            actions.submit = { _ in }
    //@endif
    //@if part.SearchView
            actions.search = { _, _ in }
    //@endif
    //@if part.CommunityCardView
            actions.subscribe = { _ in }
    //@endif
    //@if part.InstanceCardView
            actions.connect = { _ in }
            actions.favorite = { _ in }
    //@endif
            return actions
        }
    }
    """##
}
