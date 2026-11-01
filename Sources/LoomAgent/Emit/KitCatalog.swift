//  WHAT: Every file the kit can write, the parts each screen is built from, and the parts every call writes.
//  PIN:  A PART NAMES WHAT IT USES. A template refers only to the parts its `needs` list (or to others inside an
//        `//@if part.X` block), so any set of screens and features compiles; the build test proves the full set
//        and a minimal one.

import Foundation

enum KitCatalog {
    /// Every part, in the order a screen is built from them: support first, then building blocks, then screens.
    static let parts: [KitPart] = [
        KitPart("SocialValue", Template.socialValue),
        KitPart("SocialFormat", Template.socialFormat),
        KitPart("SocialContext", Template.socialContext),
        KitPart("SocialStyle", Template.socialStyle),
        KitPart("SocialActions", Template.socialActions),
        KitPart("SocialPhase", Template.socialPhase),
        KitPart("SocialMenu", views: ["SocialMenuButton"], Template.socialMenu),
        KitPart("SocialThread", Template.socialThread),
        KitPart("SocialSwipe", feature: .swipeActions, Template.socialSwipe),
        KitPart("SocialKeywordFilter", Template.socialKeywordFilter),
        KitPart("AvatarView", views: ["AvatarView"], Template.avatarView),
        KitPart("BannerView", views: ["BannerView"], Template.bannerView),
        KitPart("CensorView", views: ["CensorView"], Template.censorView),
        KitPart("MarkdownBodyView", views: ["MarkdownBodyView"], Template.markdownBodyView),
        KitPart("LinkPreviewView", views: ["LinkPreviewView"], feature: .linkPreview, Template.linkPreviewView),
        KitPart("MediaGalleryView", views: ["MediaGalleryView", "MediaThumbnailView"], feature: .media, Template.mediaGalleryView),
        KitPart("ContentStateView", views: ["ContentStateView"], needs: ["SocialPhase"], Template.contentStateView),
        KitPart("ContentMenuView", views: ["ContentMenuView", "ContentMenuItems"], Template.contentMenuView),
        KitPart("ContentHeaderView", views: ["ContentHeaderView"], needs: ["AvatarView", "ContentMenuView"], Template.contentHeaderView),
        KitPart("ContentFooterView", views: ["ContentFooterView"], Template.contentFooterView),
        KitPart("PostCardView", views: ["PostCardView"],
                needs: ["AvatarView", "ContentHeaderView", "ContentFooterView", "ContentMenuView", "CensorView", "MarkdownBodyView"],
                when: [([.linkPreview], "LinkPreviewView"), ([.media], "MediaGalleryView")], Template.postCardView),
        KitPart("CommentCardView", views: ["CommentCardView"],
                needs: ["AvatarView", "ContentHeaderView", "ContentFooterView", "ContentMenuView", "CensorView", "MarkdownBodyView"],
                when: [([.swipeActions, .reply], "SocialSwipe")], Template.commentCardView),
        KitPart("CommentThreadView", views: ["CommentThreadView"], needs: ["CommentCardView", "SocialThread", "ContentStateView"],
                Template.commentThreadView),
        KitPart("PostPageView", views: ["PostPageView"],
                needs: ["PostCardView", "CommentThreadView", "ContentHeaderView", "ContentFooterView", "MarkdownBodyView",
                        "AvatarView", "CensorView", "SocialMenu"],
                when: [([.linkPreview], "LinkPreviewView"), ([.media], "MediaGalleryView")], Template.postPageView),
        KitPart("FeedHeaderView", views: ["FeedHeaderView"], needs: ["SocialMenu", "SocialPhase"], Template.feedHeaderView),
        KitPart("FeedView", views: ["FeedView"], needs: ["PostCardView", "FeedHeaderView", "ContentStateView"], Template.feedView),
        KitPart("FeedSplitView", views: ["FeedSplitView"], needs: ["FeedView"], Template.feedSplitView),
        KitPart("MarkdownEditorView", views: ["MarkdownEditorView"], needs: ["MarkdownBodyView"], Template.markdownEditorView),
        KitPart("ComposeView", views: ["ComposeView"], needs: ["MarkdownEditorView", "AvatarView"], Template.composeView),
        KitPart("ReplyView", views: ["ReplyView"], needs: ["MarkdownEditorView", "MarkdownBodyView", "AvatarView"], Template.replyView),
        KitPart("UserCardView", views: ["UserCardView"], needs: ["AvatarView"], Template.userCardView),
        KitPart("UserProfileHeaderView", views: ["UserProfileHeaderView"], needs: ["AvatarView", "BannerView", "MarkdownBodyView"],
                Template.userProfileHeaderView),
        KitPart("ProfileView", views: ["ProfileView"],
                needs: ["UserProfileHeaderView", "PostCardView", "CommentCardView", "ContentStateView"], Template.profileView),
        KitPart("CommunityCardView", views: ["CommunityCardView"], needs: ["AvatarView"], Template.communityCardView),
        KitPart("CommunityPickerView", views: ["CommunityPickerView"], needs: ["CommunityCardView", "ContentStateView", "SocialMenu"],
                Template.communityPickerView),
        KitPart("CommunitySidebarView", views: ["CommunitySidebarView"], needs: ["CommunityCardView", "BannerView", "MarkdownBodyView"],
                Template.communitySidebarView),
        KitPart("SearchView", views: ["SearchView"],
                needs: ["PostCardView", "CommentCardView", "UserCardView", "CommunityCardView", "ContentStateView"], Template.searchView),
        KitPart("InstanceCardView", views: ["InstanceCardView", "LatencyBars"], needs: ["AvatarView", "BannerView", "MarkdownBodyView"],
                Template.instanceCardView),
        KitPart("KeywordFilterView", views: ["KeywordFilterView"], needs: ["SocialKeywordFilter"], Template.keywordFilterView),
        KitPart("ShareImageView", views: ["ShareImageView"], needs: ["PostCardView", "CommentCardView"], Template.shareImageView),
        KitPart("ReportView", views: ["ReportView"], feature: .report, Template.reportView),
        KitPart("SocialPreviews", Template.socialPreviews),
    ]

    /// What every call writes, whatever its screens.
    static let core = ["SocialValue", "SocialFormat", "SocialContext", "SocialStyle", "SocialActions", "SocialPhase", "SocialPreviews"]

    /// The parts a screen is.
    static func roots(of screen: LoomScreen) -> [String] {
        switch screen {
        case .feed: return ["FeedView", "FeedHeaderView", "FeedSplitView"]
        case .post: return ["PostCardView", "PostPageView"]
        case .thread: return ["CommentThreadView"]
        case .compose: return ["ComposeView"]
        case .reply: return ["ReplyView"]
        case .profile: return ["UserCardView", "UserProfileHeaderView", "ProfileView"]
        case .community: return ["CommunityCardView", "CommunityPickerView", "CommunitySidebarView"]
        case .search: return ["SearchView"]
        case .instances: return ["InstanceCardView"]
        case .filter: return ["KeywordFilterView"]
        case .share: return ["ShareImageView"]
        }
    }

    static func part(_ name: String) -> KitPart? { parts.first { $0.name == name } }
}
