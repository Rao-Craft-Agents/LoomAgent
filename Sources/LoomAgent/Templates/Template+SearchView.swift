//  WHAT: The template of `SearchView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let searchView = ##"""
    import SwiftUI

    /// Where results are scoped: everything at once, or one kind.
    enum SocialSearchScope: String, CaseIterable, Identifiable, Hashable, Sendable {
        case all, posts, comments, users, communities

        var id: Self { self }

        var title: LocalizedStringKey {
            switch self {
            case .all: return "All"
            case .posts: return "Posts"
            case .comments: return "Comments"
            case .users: return "Users"
            case .communities: return "Communities"
            }
        }
    }

    /// Search, as Loom lays it out: the field, the kind of result, then the results. *All* shows a row each of
    /// communities, people, posts and comments that scrolls sideways; one kind shows a list. A search starts a moment
    /// after typing stops, on return, and when the kind changes; the app sets the results and the phase.
    struct SearchView<Social: SocialSchema>: View {
        @Binding var query: String
        @Binding var scope: SocialSearchScope
        var posts: [Social.Post] = []
        var comments: [Social.Comment] = []
        var users: [Social.User] = []
        var communities: [Social.Community] = []
        var phase: SocialPhase = .idle
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        /// The last search asked for, so return and the pause after typing do not ask twice.
        @State private var asked: String?

        var body: some View {
            let palette = style.palette
            VStack(spacing: 0) {
                HStack(spacing: SocialSpacing.layer2) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(palette.secondaryForeground)
                        .accessibilityHidden(true)
                    TextField("Search", text: $query)
                        .textFieldStyle(.plain)
                        .font(.headline)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit { Task { await search() } }
                    if phase.isLoading {
                        ProgressView().controlSize(.small)
                    }
                    if !query.isEmpty {
                        Button { query = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(palette.secondaryForeground)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Clear"))
                    }
                }
                .padding(.horizontal, SocialSpacing.layer4)
                .frame(height: 48)
                Divider()
                Picker("Results", selection: $scope) {
                    ForEach(SocialSearchScope.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(SocialSpacing.layer3)
                Divider()
                ScrollView {
                    if scope == .all {
                        everything(palette)
                    } else {
                        list(palette)
                    }
                }
                .background(palette.alternateBackground)
            }
            .foregroundStyle(palette.foreground)
            .background(palette.background)
            .socialContext(.search)
            .task(id: "\(scope.rawValue) \(query)") {
                // A moment after typing stops: each keystroke cancels the last wait.
                try? await Task.sleep(nanoseconds: 600_000_000)
                guard !Task.isCancelled else { return }
                await search()
            }
        }

        private func search() async {
            let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = "\(scope.rawValue) \(text)"
            guard !text.isEmpty, key != asked else { return }
            asked = key
            await actions.search?(text, scope)
        }

        // MARK: All

        private func everything(_ palette: SocialPalette) -> some View {
            LazyVStack(alignment: .leading, spacing: 0) {
                section("Communities", isEmpty: communities.isEmpty, empty: "No communities found") {
                    ForEach(communities) { community in
                        CommunityCardView(community: community, actions: actions, showsCounts: false)
                            .frame(width: 300)
                    }
                }
                Divider()
                section("Users", isEmpty: users.isEmpty, empty: "No users found") {
                    ForEach(users) { user in
                        UserCardView(user: user, actions: actions, isCompact: true)
                    }
                }
                Divider()
                section("Posts", isEmpty: posts.isEmpty, empty: "No posts found") {
                    ForEach(posts) { post in
                        PostCardView(post: post, actions: actions)
                            .frame(width: 320, height: 240, alignment: .top)
                            .clipped()
                    }
                }
                Divider()
                section("Comments", isEmpty: comments.isEmpty, empty: "No comments found") {
                    ForEach(comments) { comment in
                        CommentCardView(comment: comment, actions: actions)
                            .frame(width: 320, height: 240, alignment: .top)
                            .clipped()
                    }
                }
            }
            .background(palette.background)
        }

        private func section<Content: View>(_ title: LocalizedStringKey, isEmpty: Bool, empty: LocalizedStringKey,
                                            @ViewBuilder content: () -> Content) -> some View {
            VStack(alignment: .leading, spacing: SocialSpacing.layer3) {
                Text(title)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, SocialSpacing.layer4)
                if isEmpty {
                    Text(empty)
                        .font(.subheadline)
                        .padding(.horizontal, SocialSpacing.layer4)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(alignment: .top, spacing: SocialSpacing.layer4) {
                            content()
                        }
                        .padding(.horizontal, SocialSpacing.layer4)
                    }
                }
            }
            .padding(.vertical, SocialSpacing.layer4)
        }

        // MARK: One kind

        @ViewBuilder
        private func list(_ palette: SocialPalette) -> some View {
            LazyVStack(spacing: 0) {
                switch scope {
                case .posts:
                    ForEach(posts) { post in
                        PostCardView(post: post, actions: actions)
                        Divider()
                    }
                case .comments:
                    ForEach(comments) { comment in
                        CommentCardView(comment: comment, actions: actions)
                        Divider()
                    }
                case .users:
                    ForEach(users) { user in
                        UserCardView(user: user, actions: actions, showsCounts: true)
                            .padding(SocialSpacing.layer4)
                    }
                case .communities:
                    ForEach(communities) { community in
                        CommunityCardView(community: community, actions: actions)
                            .padding(SocialSpacing.layer4)
                    }
                case .all:
                    EmptyView()
                }
                if count == 0 {
                    ContentStateView(phase: phase, empty: "Nothing found", retry: nil)
                } else {
                    ContentStateView(phase: phase, empty: "Nothing found", retry: actions.loadMore, isFooter: true)
                        .task(id: count) {
                            if phase.wantsMore { await actions.loadMore?() }
                        }
                }
            }
            .background(palette.background)
        }

        private var count: Int {
            switch scope {
            case .all: return posts.count + comments.count + users.count + communities.count
            case .posts: return posts.count
            case .comments: return comments.count
            case .users: return users.count
            case .communities: return communities.count
            }
        }
    }

    private struct SearchPreview: View {
        @State private var query = "soup"
        @State private var scope = SocialSearchScope.all

        var body: some View {
            SearchView(query: $query, scope: $scope, posts: SocialSample.posts, comments: SocialSample.comments,
                       users: SocialSample.users, communities: SocialSample.communities, phase: .exhausted,
                       actions: SocialActions<SocialSample>.sample)
        }
    }

    #Preview {
        SearchPreview()
    }
    """##
}
