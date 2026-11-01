//  WHAT: The template of `SocialActions.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialActions = ##"""
    import SwiftUI

    /// What the social views can ask the app to do. A view never routes and never calls a network: it calls one of
    /// these, and the app does the rest. A view shows a control only when its closure is set, so an app that cannot
    /// vote leaves `vote` out and no arrow is drawn. Links open with the system when `openLink` is left out.
    ///
    ///     let actions = SocialActions<AppSocial>(
    ///         vote: { target, vote in feed.vote(target, vote) },
    ///         openPost: { post in path.append(post.id) },
    ///         loadMore: { await feed.loadMore() },
    ///         refresh: { await feed.refresh() })
    struct SocialActions<Social: SocialSchema> {
    //@if vote
        /// Votes on a post or a comment: `.up`, `.down`, or `.none` to take the vote back.
        var vote: (@MainActor (SocialTarget<Social>, SocialVote) -> Void)?
    //@endif
    //@if save
        /// Saves a post or a comment, or unsaves it when it is saved.
        var save: (@MainActor (SocialTarget<Social>) -> Void)?
    //@endif
    //@if share
        /// Shares a post, a comment, a person or a community: the app presents its share sheet or `ShareImageView`.
        var share: (@MainActor (SocialTarget<Social>) -> Void)?
    //@endif
    //@if reply
        /// Starts a reply to a post or a comment: the app presents `ReplyView`.
        var reply: (@MainActor (SocialTarget<Social>) -> Void)?
    //@endif
    //@if report
        /// Starts a report: the app presents `ReportView`.
        var report: (@MainActor (SocialTarget<Social>) -> Void)?
        /// Sends a report with the reason the person gave.
        var sendReport: (@MainActor (SocialTarget<Social>, String) async throws -> Void)?
    //@endif
    //@if block
        /// Blocks the author of a post or a comment, a person, or a community; unblocks one that is blocked.
        var block: (@MainActor (SocialTarget<Social>) -> Void)?
    //@endif
    //@if editing
        /// Edits a post or a comment the person wrote.
        var edit: (@MainActor (SocialTarget<Social>) -> Void)?
        /// Deletes a post or a comment the person wrote, or restores it when it is deleted.
        var delete: (@MainActor (SocialTarget<Social>) -> Void)?
    //@endif
        /// Opens a post's page.
        var openPost: (@MainActor (Social.Post) -> Void)?
        /// Opens a profile: of a person, or of the author of a post or a comment.
        var openUser: (@MainActor (SocialTarget<Social>) -> Void)?
        /// Opens a community's feed: of a community, or of the community a post is in.
        var openCommunity: (@MainActor (SocialTarget<Social>) -> Void)?
        /// Opens a link; the system opens it when this is left out.
        var openLink: (@MainActor (URL) -> Void)?
        /// Asks for the next page of a list; the list shows the phase the app sets.
        var loadMore: (@MainActor () async -> Void)?
        /// Asks for a list again from the top: pull to refresh, and the retry of an empty list.
        var refresh: (@MainActor () async -> Void)?
    //@if part.ComposeView || part.ReplyView
        /// Posts a draft: a new post, a reply, or an edit. A thrown error is shown and the draft is kept.
        var submit: (@MainActor (SocialDraft<Social>) async throws -> Void)?
    //@endif
    //@if part.SearchView
        /// Searches for `query` in `scope`; the app sets the results and the phase.
        var search: (@MainActor (String, SocialSearchScope) async -> Void)?
    //@endif
    //@if part.CommunityCardView
        /// Subscribes to a community, or unsubscribes when subscribed.
        var subscribe: (@MainActor (Social.Community) -> Void)?
    //@endif
    //@if part.InstanceCardView
        /// Connects the app to an instance.
        var connect: (@MainActor (Social.Instance) -> Void)?
        /// Stars an instance, or unstars it.
        var favorite: (@MainActor (Social.Instance) -> Void)?
    //@endif
    }
    //@if part.ComposeView || part.ReplyView

    /// What the person wrote, as the app posts it: a new post, a reply, or an edit.
    struct SocialDraft<Social: SocialSchema> {
        /// A new post's title; empty for a reply.
        var title = ""
        /// The text, in Markdown.
        var body = ""
        /// The link a post shares.
        var link: URL?
        /// A picture to attach, as the photo library gave it.
        var image: Data?
        /// The community a post goes to.
        var community: Social.Community?
        /// What a reply answers.
        var replyingTo: SocialTarget<Social>?
        /// What an edit changes.
        var editing: SocialTarget<Social>?
    }
    //@endif

    extension View {
        /// Pull to refresh when the app can refresh, and nothing to pull when it cannot.
        @ViewBuilder
        func socialRefreshable(_ refresh: (@MainActor () async -> Void)?) -> some View {
            if let refresh {
                self.refreshable { await refresh() }
            } else {
                self
            }
        }
    }
    """##
}
