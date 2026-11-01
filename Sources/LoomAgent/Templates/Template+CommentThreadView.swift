//  WHAT: The template of `CommentThreadView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let commentThreadView = ##"""
    import SwiftUI

    /// A post's comments as a thread: each reply under the comment it answers, indented with a guide line per level,
    /// folded away by a tap on its comment's header. Put it in a `ScrollView`, as `PostPageView` does; it asks for more
    /// at its end while the phase says there is more.
    struct CommentThreadView<Social: SocialSchema>: View {
        var comments: [Social.Comment]
        var phase: SocialPhase = .idle
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        @State private var folded: Set<Social.Comment.ID> = []

        /// How far a reply sits in from the comment it answers.
        private let step: CGFloat = SocialSpacing.layer3
        /// The deepest a reply is indented; deeper ones line up with it.
        private let deepest = 6

        var body: some View {
            let palette = style.palette
            LazyVStack(alignment: .leading, spacing: 0) {
                if comments.isEmpty {
                    ContentStateView(phase: phase, empty: "No comments", retry: actions.refresh)
                } else {
                    ForEach(SocialThread(comments, folded: folded).rows) { row in
                        let depth = min(row.depth, deepest)
                        CommentCardView(comment: row.comment, actions: actions, isFolded: folded.contains(row.id)) {
                            withAnimation(.snappy) { toggle(row.id) }
                        }
                        .padding(.leading, CGFloat(depth) * step)
                        .overlay(alignment: .leading) { guides(depth, palette) }
                        Divider()
                            .padding(.leading, CGFloat(depth) * step)
                    }
                    ContentStateView(phase: phase, empty: "No comments", retry: actions.loadMore, isFooter: true)
                        .task(id: comments.count) {
                            if phase.wantsMore { await actions.loadMore?() }
                        }
                }
            }
            .socialContext(.thread)
        }

        /// One thin line a level, at the edge of each indent.
        private func guides(_ depth: Int, _ palette: SocialPalette) -> some View {
            HStack(spacing: 0) {
                ForEach(0..<depth, id: \.self) { _ in
                    Rectangle()
                        .fill(palette.foreground.opacity(0.15))
                        .frame(width: 1)
                        .frame(width: step, alignment: .trailing)
                }
            }
            .accessibilityHidden(true)
        }

        private func toggle(_ id: Social.Comment.ID) {
            if folded.contains(id) { folded.remove(id) } else { folded.insert(id) }
        }
    }

    #Preview {
        ScrollView {
            CommentThreadView(comments: SocialSample.comments, actions: .sample)
        }
    }
    """##
}
