//  WHAT: The template of `FeedSplitView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let feedSplitView = ##"""
    import SwiftUI

    /// Loom's expanded layout for iPad and the Mac: a sidebar, the feed, and the post chosen in it side by side, with
    /// a button to fold the post away. A post opened from the feed is chosen here instead of opened; on a compact
    /// iPhone screen only the feed shows and the app's `openPost` opens posts.
    ///
    ///     FeedSplitView(selection: $chosen, actions: actions) {
    ///         CommunityPickerView(communities: communities, actions: actions)
    ///     } feed: { actions in
    ///         FeedView(title: Text("Front Page"), posts: posts, phase: phase, actions: actions)
    ///     } detail: { id in
    ///         if let post = posts.first(where: { $0.id == id }) {
    ///             PostPageView(post: post, comments: comments, actions: actions)
    ///         }
    ///     }
    struct FeedSplitView<Social: SocialSchema, Sidebar: View, Feed: View, Detail: View>: View {
        @Binding var selection: Social.Post.ID?
        var actions: SocialActions<Social>
        @ViewBuilder var sidebar: () -> Sidebar
        /// The feed, given the actions to use: they choose a post here rather than open it.
        @ViewBuilder var feed: (SocialActions<Social>) -> Feed
        @ViewBuilder var detail: (Social.Post.ID) -> Detail

        @Environment(\.socialStyle) private var style
        #if os(iOS)
        @Environment(\.horizontalSizeClass) private var sizeClass
        #endif
        @State private var detailFolded = false

        private var isExpanded: Bool {
            #if os(iOS)
            return sizeClass == .regular
            #else
            return true
            #endif
        }

        var body: some View {
            if isExpanded {
                HStack(spacing: 0) {
                    sidebar()
                        .frame(width: 300)
                    Divider()
                    feed(choosing)
                        .frame(minWidth: 360, maxWidth: .infinity)
                    if let id = selection {
                        Divider()
                        if !detailFolded {
                            detail(id)
                                .frame(minWidth: 360, maxWidth: .infinity)
                                .id(id)
                            Divider()
                        }
                        foldButton
                    }
                }
                .background(style.palette.background)
            } else {
                feed(actions)
            }
        }

        /// The app's actions, with opening a post turned into choosing it.
        private var choosing: SocialActions<Social> {
            var actions = self.actions
            let selection = $selection
            actions.openPost = { post in
                selection.wrappedValue = post.id
            }
            return actions
        }

        private var foldButton: some View {
            Button {
                withAnimation(.snappy) { detailFolded.toggle() }
            } label: {
                Image(systemName: detailFolded ? "chevron.left.2" : "chevron.right.2")
                    .font(.title3)
                    .foregroundStyle(style.palette.foreground)
                    .frame(width: 36)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(style.palette.background)
            .accessibilityLabel(detailFolded ? Text("Show post") : Text("Hide post"))
        }
    }

    private struct FeedSplitPreview: View {
        @State private var chosen: SocialSample.Post.ID? = SocialSample.posts.first?.id

        var body: some View {
            FeedSplitView(selection: $chosen, actions: SocialActions<SocialSample>.sample) {
                List(SocialSample.communities) { Text(verbatim: $0.socialName) }
            } feed: { actions in
                FeedView(title: Text("Front Page"), posts: SocialSample.posts, phase: .exhausted, actions: actions)
            } detail: { id in
    //@if part.PostPageView
                if let post = SocialSample.posts.first(where: { $0.id == id }) {
                    PostPageView(post: post, comments: SocialSample.comments, phase: .exhausted, actions: .sample)
                }
    //@else
                if let post = SocialSample.posts.first(where: { $0.id == id }) {
                    ScrollView { PostCardView(post: post, actions: .sample) }
                }
    //@endif
            }
        }
    }

    #Preview {
        FeedSplitPreview()
    }
    """##
}
