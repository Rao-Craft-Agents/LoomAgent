//  WHAT: The template of `ContentFooterView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let contentFooterView = ##"""
    import SwiftUI

    /// The bottom of a post or a comment: its votes and score, its comments or replies, save and share. Loom stacks
    /// the buttons over a line of counts; a timeline puts each count beside its button; a reader row keeps the score
    /// between the arrows. A vote shows at once and gives way to the app's value when that arrives.
    struct ContentFooterView<Social: SocialSchema>: View {
        var target: SocialTarget<Social>
        var actions: SocialActions<Social>
        /// Heads a page: a reply button joins the row.
        var isHeader = false

        @Environment(\.socialStyle) private var style
        @Environment(\.socialContext) private var context
    //@if vote
        /// The vote just made, shown until the app's own value changes.
        @State private var pendingVote: SocialVote?
    //@endif

        var body: some View {
            let palette = style.palette
            let info = target.content
            Group {
                switch style {
                case .loom:
                    VStack(alignment: .leading, spacing: SocialSpacing.layer3) {
                        if context.isInteractive {
                            HStack(spacing: SocialSpacing.layer4) {
                                buttons(info, palette, counts: false)
                                Spacer(minLength: 0)
                                replyButton(palette)
                            }
                            .frame(height: 20)
                        }
                        summary(info, palette)
                    }
                case .social:
                    HStack(spacing: SocialSpacing.layer5) {
                        buttons(info, palette, counts: true)
                        Spacer(minLength: 0)
                        replyButton(palette)
                        symbols(info, palette)
                    }
                    .frame(height: 20)
                case .reader:
                    HStack(spacing: SocialSpacing.layer4) {
                        buttons(info, palette, counts: true)
                        Spacer(minLength: 0)
                        replyButton(palette)
                        symbols(info, palette)
                    }
                    .frame(height: 20)
                }
            }
            .font(.headline)
            .foregroundStyle(palette.foreground)
            .buttonStyle(.plain)
    //@if vote
            .onChange(of: info?.myVote) { pendingVote = nil }
            .sensoryFeedback(.selection, trigger: pendingVote)
    //@endif
        }

        // MARK: Parts

        @ViewBuilder
        private func buttons(_ info: SocialContentInfo?, _ palette: SocialPalette, counts: Bool) -> some View {
    //@if vote
            if let vote = actions.vote, context.isInteractive {
                let current = pendingVote ?? info?.myVote ?? .none
                HStack(spacing: counts ? SocialSpacing.layer2 : SocialSpacing.layer4) {
                    Button { cast(.up, from: current, vote) } label: {
                        HStack(spacing: SocialSpacing.layer2) {
                            Image(systemName: "arrow.up").font(.headline.bold())
                            if counts { Text(verbatim: SocialFormat.count(shownScore(info, current))).font(.subheadline) }
                        }
                        .foregroundStyle(current == .up ? palette.upvote : palette.foreground)
                        .contentShape(Rectangle())
                    }
                    .accessibilityLabel(current == .up ? Text("Remove upvote") : Text("Upvote"))
                    Button { cast(.down, from: current, vote) } label: {
                        Image(systemName: "arrow.down").font(.headline.bold())
                            .foregroundStyle(current == .down ? palette.downvote : palette.foreground)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(current == .down ? Text("Remove downvote") : Text("Downvote"))
                }
            }
    //@endif
            if case .post(let post) = target, context != .post {
                Button { actions.openPost?(post) } label: {
                    HStack(spacing: SocialSpacing.layer2) {
                        Image(systemName: "bubble.left")
                        if counts { Text(verbatim: SocialFormat.count(info?.replies ?? 0)).font(.subheadline) }
                    }
                    .contentShape(Rectangle())
                }
                .disabled(actions.openPost == nil)
                .accessibilityLabel(Text("Comments"))
            }
    //@if save
            if let save = actions.save, context.isInteractive {
                Button { save(target) } label: {
                    Image(systemName: info?.isSaved == true ? "bookmark.fill" : "bookmark")
                        .font(counts ? .subheadline : .headline)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(info?.isSaved == true ? Text("Remove bookmark") : Text("Bookmark"))
            }
    //@endif
    //@if share
            if let share = actions.share, context.isInteractive {
                Button { share(target) } label: {
                    Image(systemName: "paperplane")
                        .font(counts ? .subheadline : .headline)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text("Share"))
            }
    //@endif
        }

        @ViewBuilder
        private func replyButton(_ palette: SocialPalette) -> some View {
    //@if reply
            if isHeader, context.isInteractive, let reply = actions.reply {
                Button { reply(target) } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(palette.foreground)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text("Reply"))
            }
    //@endif
        }

        /// Loom's line of counts: `12 up  3 down • 4 replies`, with a pin, a lock or where it came from.
        private func summary(_ info: SocialContentInfo?, _ palette: SocialPalette) -> some View {
    //@if vote
            let current = pendingVote ?? info?.myVote ?? .none
    //@else
            let current = info?.myVote ?? .none
    //@endif
            return HStack(spacing: 0) {
                if let up = info?.upvotes {
                    let shift = current.rawValue - (info?.myVote.rawValue ?? 0)
                    Text("\(SocialFormat.count(max(0, up + (shift > 0 ? shift : 0)))) up")
                        .padding(.trailing, SocialSpacing.layer4)
                    Text("\(SocialFormat.count(max(0, (info?.downvotes ?? 0) - (shift < 0 ? shift : 0)))) down")
                } else {
                    Text("\(SocialFormat.count(shownScore(info, current))) points")
                }
                Text(verbatim: "•")
                    .font(.footnote)
                    .padding(.horizontal, SocialSpacing.layer2)
                replies(info?.replies ?? 0)
                symbols(info, palette)
            }
            .font(.subheadline)
            .foregroundStyle(palette.foreground.opacity(0.5))
            .lineLimit(1)
        }

        @ViewBuilder
        private func replies(_ count: Int) -> some View {
            if count == 1 {
                Text("1 reply")
            } else {
                Text("\(count) replies")
            }
        }

        /// A pin, a lock, and where the content came from, each after a dot, kept together.
        private func symbols(_ info: SocialContentInfo?, _ palette: SocialPalette) -> some View {
            HStack(spacing: 0) {
                if info?.isPinned == true {
                    dot(palette)
                    Image(systemName: "pin").font(.caption).foregroundStyle(palette.pinned)
                        .accessibilityLabel(Text("Pinned"))
                }
                if info?.isLocked == true {
                    dot(palette)
                    Image(systemName: "lock").font(.caption).foregroundStyle(palette.locked)
                        .accessibilityLabel(Text("Locked"))
                }
                if let source = info?.source {
                    dot(palette)
                    Text(verbatim: source).font(.footnote).foregroundStyle(palette.accent)
                }
            }
            .fixedSize()
        }

        private func dot(_ palette: SocialPalette) -> some View {
            Text(verbatim: "•")
                .font(.footnote)
                .padding(.horizontal, SocialSpacing.layer2)
                .foregroundStyle(palette.foreground.opacity(0.5))
        }

        // MARK: Voting

        /// The score with the vote just made counted.
        private func shownScore(_ info: SocialContentInfo?, _ current: SocialVote) -> Int {
            (info?.score ?? 0) - (info?.myVote.rawValue ?? 0) + current.rawValue
        }
    //@if vote

        private func cast(_ arrow: SocialVote, from current: SocialVote, _ vote: @MainActor (SocialTarget<Social>, SocialVote) -> Void) {
            let next = current.tapping(arrow)
            pendingVote = next
            vote(target, next)
        }
    //@endif
    }

    #Preview {
        VStack(alignment: .leading, spacing: SocialSpacing.layer5) {
            ForEach(SocialStyle.allCases) { style in
                ContentFooterView(target: .post(SocialSample.posts[1]), actions: .sample)
                    .socialStyle(style)
            }
        }
        .padding()
    }
    """##
}
