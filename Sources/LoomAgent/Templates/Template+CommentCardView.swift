//  WHAT: The template of `CommentCardView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let commentCardView = ##"""
    import SwiftUI

    /// A comment as a thread shows it: Loom hangs it off the author's avatar, ringed blue when they wrote the post and
    /// red when they run the place, with a line down while it has replies; then its text in Markdown and its votes.
    /// A tap on its header folds its replies away. On iPhone and iPad a swipe toward the leading edge replies; on the
    /// Mac its menu is also its context menu.
    struct CommentCardView<Social: SocialSchema>: View {
        var comment: Social.Comment
        var actions: SocialActions<Social>
        /// Whether its replies are folded away: only its header shows.
        var isFolded = false
        /// Folds its replies away, or back.
        var fold: (() -> Void)? = nil

        @Environment(\.socialStyle) private var style
        @Environment(\.socialContext) private var context

        var body: some View {
            let palette = style.palette
            let info = SocialContentInfo(comment)
            Group {
                if style.usesAvatarColumn {
                    HStack(alignment: .top, spacing: SocialSpacing.layer3) {
                        avatarColumn(info, palette)
                        VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                            ContentHeaderView(target: .comment(comment), actions: actions, toggle: fold)
                            if !isFolded { content(info, palette) }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                        ContentHeaderView(target: .comment(comment), actions: actions, toggle: fold)
                        if !isFolded { content(info, palette) }
                    }
                }
            }
            .padding(.top, style == .loom ? SocialSpacing.layer5 : SocialSpacing.layer3)
            .padding(.bottom, style == .loom ? SocialSpacing.layer5 : SocialSpacing.layer3)
            .padding(.leading, SocialSpacing.layer4)
            .padding(.trailing, SocialSpacing.layer3)
            .background(palette.background)
            .opacity(isFolded ? 0.7 : 1)
    //@if swipeActions && reply
    #if os(iOS)
            .socialSwipe(systemImage: "arrowshape.turn.up.backward.fill", tint: palette.swipe, label: "Reply") {
                if context.isInteractive { actions.reply?(.comment(comment)) }
            }
    #endif
    //@endif
    #if os(macOS)
            .contextMenu {
                if context.isInteractive { ContentMenuItems(target: .comment(comment), actions: actions) }
            }
    #endif
        }

        private func avatarColumn(_ info: SocialContentInfo, _ palette: SocialPalette) -> some View {
            VStack(spacing: SocialSpacing.layer3) {
                AvatarView(url: info.authorAvatar, size: .small, ring: ring(info, palette))
                    .onTapGesture { actions.openUser?(.comment(comment)) }
                if style.drawsThreadLine, info.replies > 0, !isFolded {
                    RoundedRectangle(cornerRadius: 1)
                        .fill((info.authorIsOriginalPoster || info.authorIsAdmin ? ring(info, palette).opacity(0.7) : palette.foreground.opacity(0.3)))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .contentShape(Rectangle().inset(by: -8))
                        .onTapGesture { fold?() }
                        .accessibilityHidden(true)
                }
                if info.authorIsBot {
                    Text(verbatim: "🤖")
                        .font(.title3)
                        .accessibilityLabel(Text("Bot"))
                }
            }
            .frame(width: AvatarView.Size.small.points)
            .frame(maxHeight: .infinity, alignment: .top)
        }

        @ViewBuilder
        private func content(_ info: SocialContentInfo, _ palette: SocialPalette) -> some View {
            if info.isRemoved {
                CensorView(reason: .removed, isComment: true)
            } else if info.isDeleted {
                CensorView(reason: .deleted, isComment: true)
            } else {
                if let title = comment.socialPostTitle, context != .post, context != .thread {
                    Text(verbatim: title)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryForeground)
                        .lineLimit(1)
                }
                MarkdownBodyView(text: comment.socialText, lineLimit: context.isPreview ? 6 : nil)
                    .padding(.bottom, SocialSpacing.layer1)
                ContentFooterView(target: .comment(comment), actions: actions)
            }
        }

        private func ring(_ info: SocialContentInfo, _ palette: SocialPalette) -> Color {
            if info.authorIsAdmin { return palette.admin }
            if info.authorIsOriginalPoster { return palette.originalPoster }
            return .clear
        }
    }

    #Preview {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(SocialSample.comments) { comment in
                    CommentCardView(comment: comment, actions: .sample)
                    Divider()
                }
            }
        }
        .socialContext(.thread)
    }
    """##
}
