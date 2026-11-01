//  WHAT: The template of `ProfileView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let profileView = ##"""
    import SwiftUI

    /// A person's profile: their header, then what they wrote, all of it newest first or their posts or comments
    /// alone, as Loom's large tab words choose, with more asked for at the end.
    struct ProfileView<Social: SocialSchema>: View {
        var user: Social.User
        var posts: [Social.Post]
        var comments: [Social.Comment]
        var phase: SocialPhase = .idle
        var actions: SocialActions<Social>

        enum Tab: Hashable, CaseIterable {
            case overview, posts, comments

            var title: LocalizedStringKey {
                switch self {
                case .overview: return "Overview"
                case .posts: return "Posts"
                case .comments: return "Comments"
                }
            }
        }

        @Environment(\.socialStyle) private var style
        @State private var tab: Tab = .overview

        var body: some View {
            let palette = style.palette
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    UserProfileHeaderView(user: user, actions: actions)
                    HStack(alignment: .lastTextBaseline, spacing: SocialSpacing.layer4) {
                        ForEach(Tab.allCases, id: \.self) { option in
                            Button { withAnimation(.snappy) { tab = option } } label: {
                                Text(option.title)
                                    .font(tab == option ? .title2.bold() : .title3.bold())
                                    .opacity(tab == option ? 1 : 0.6)
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(tab == option ? .isSelected : [])
                        }
                        Spacer()
                    }
                    .foregroundStyle(palette.foreground)
                    .padding(.horizontal, SocialSpacing.layer4)
                    .padding(.bottom, SocialSpacing.layer4)
                    Divider()

                    let entries = self.entries
                    if entries.isEmpty {
                        ContentStateView(phase: phase, empty: "Nothing here yet", retry: actions.refresh)
                    } else {
                        ForEach(entries) { entry in
                            switch entry {
                            case .post(let post): PostCardView(post: post, actions: actions)
                            case .comment(let comment): CommentCardView(comment: comment, actions: actions)
                            }
                            Divider()
                        }
                        ContentStateView(phase: phase, empty: "Nothing here yet", retry: actions.loadMore, isFooter: true)
                            .task(id: posts.count + comments.count) {
                                if phase.wantsMore { await actions.loadMore?() }
                            }
                    }
                }
            }
            .socialRefreshable(actions.refresh)
            .background(palette.background)
            .socialContext(.profile)
        }

        /// One row of the list: a post or a comment.
        enum Entry: Identifiable {
            case post(Social.Post)
            case comment(Social.Comment)

            var id: String {
                switch self {
                case .post(let post): return "post-\(post.id)"
                case .comment(let comment): return "comment-\(comment.id)"
                }
            }

            var date: Date {
                switch self {
                case .post(let post): return post.socialCreated ?? .distantPast
                case .comment(let comment): return comment.socialCreated ?? .distantPast
                }
            }
        }

        private var entries: [Entry] {
            switch tab {
            case .posts: return posts.map(Entry.post)
            case .comments: return comments.map(Entry.comment)
            case .overview: return (posts.map(Entry.post) + comments.map(Entry.comment)).sorted { $0.date > $1.date }
            }
        }
    }

    #Preview {
        ProfileView(user: SocialSample.users[0], posts: SocialSample.posts, comments: SocialSample.comments,
                    phase: .exhausted, actions: .sample)
    }
    """##
}
