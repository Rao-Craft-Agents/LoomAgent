//  WHAT: The template of `FeedView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let feedView = ##"""
    import SwiftUI

    /// A feed of posts: its header with its menus, one card a post with a divider between, pull to refresh, and more
    /// asked for as the end comes into view. With no posts it shows the spinner, the empty state or the error and a
    /// way to try again; at its end, the same for the next page.
    struct FeedView<Social: SocialSchema, Accessory: View>: View {
        var title: Text? = nil
        var subtitle: Text? = nil
        var posts: [Social.Post]
        var phase: SocialPhase = .idle
        var menus: [SocialMenu] = []
        var actions: SocialActions<Social>
        /// What the feed says when it has no posts.
        var empty: LocalizedStringKey = "No posts"
        /// The end of the header's row: the account, a search button.
        @ViewBuilder var accessory: () -> Accessory

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            ScrollView {
                LazyVStack(spacing: 0) {
                    if title != nil || subtitle != nil || !menus.isEmpty {
                        FeedHeaderView(title: title, subtitle: subtitle, menus: menus,
                                       phase: posts.isEmpty ? .idle : phase, retry: actions.refresh, accessory: accessory)
                        Divider()
                    }
                    if posts.isEmpty {
                        ContentStateView(phase: phase, empty: empty, retry: actions.refresh)
                    } else {
                        ForEach(posts) { post in
                            PostCardView(post: post, actions: actions)
                            Divider()
                        }
                        ContentStateView(phase: phase, empty: empty, retry: actions.loadMore, isFooter: true)
                            .task(id: posts.count) {
                                if phase.wantsMore { await actions.loadMore?() }
                            }
                    }
                }
            }
            .socialRefreshable(actions.refresh)
            .background(palette.background)
            .socialContext(.feed)
        }
    }

    extension FeedView where Accessory == EmptyView {
        init(title: Text? = nil, subtitle: Text? = nil, posts: [Social.Post], phase: SocialPhase = .idle,
             menus: [SocialMenu] = [], actions: SocialActions<Social>, empty: LocalizedStringKey = "No posts") {
            self.init(title: title, subtitle: subtitle, posts: posts, phase: phase, menus: menus, actions: actions,
                      empty: empty) { EmptyView() }
        }
    }

    #Preview("Feed") {
        FeedView(title: Text("Front Page"), subtitle: Text(verbatim: "kitchen.social"), posts: SocialSample.posts,
                 phase: .exhausted, actions: .sample)
    }

    #Preview("Empty") {
        FeedView(title: Text("Front Page"), posts: [SocialSample.Post](), phase: .idle, actions: .sample)
    }
    """##
}
