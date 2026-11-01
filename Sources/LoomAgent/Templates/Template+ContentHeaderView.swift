//  WHAT: The template of `ContentHeaderView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let contentHeaderView = ##"""
    import SwiftUI

    /// The top line of a post or a comment: who wrote it, where they are from, when, whether it was edited, and its
    /// menu. Loom stacks the name over the handle; a timeline puts them on one line; a reader row leads with the
    /// community.
    struct ContentHeaderView<Social: SocialSchema>: View {
        var target: SocialTarget<Social>
        var actions: SocialActions<Social>
        /// Folds a comment's replies away or back: a tap on the header in a thread.
        var toggle: (() -> Void)? = nil

        @Environment(\.socialStyle) private var style
        @Environment(\.socialContext) private var context

        var body: some View {
            let palette = style.palette
            let info = target.content
            HStack(alignment: .center, spacing: SocialSpacing.layer2) {
                switch style {
                case .loom:
                    byline(info, palette)
                case .social:
                    timelineLine(info, palette)
                case .reader:
                    placeLine(info, palette)
                }
                Spacer(minLength: 0)
                if style != .reader {
                    time(info, palette, font: style == .loom ? .footnote : .subheadline)
                }
                if context.isInteractive {
                    ContentMenuView(target: target, actions: actions)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { toggle?() }
        }

        /// Loom's: the name in bold over where they are from.
        private func byline(_ info: SocialContentInfo?, _ palette: SocialPalette) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: info?.authorName ?? "")
                    .font(.headline)
                    .foregroundStyle(palette.foreground)
                    .lineLimit(1)
                if let handle = info?.authorHandle {
                    Text(verbatim: "@" + handle)
                        .font(.caption2)
                        .foregroundStyle(palette.foreground.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .onTapGesture { openAuthor() }
            .accessibilityAddTraits(actions.openUser == nil ? [] : .isButton)
        }

        /// A timeline's: the name, the handle and nothing else on one line.
        private func timelineLine(_ info: SocialContentInfo?, _ palette: SocialPalette) -> some View {
            HStack(spacing: SocialSpacing.layer1) {
                Text(verbatim: info?.authorName ?? "")
                    .font(.subheadline.bold())
                    .foregroundStyle(palette.foreground)
                if let handle = info?.authorHandle {
                    Text(verbatim: "@" + handle)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryForeground)
                }
            }
            .lineLimit(1)
            .onTapGesture { openAuthor() }
            .accessibilityAddTraits(actions.openUser == nil ? [] : .isButton)
        }

        /// A reader row's: the community (or, for a comment, the author) with a small picture, then the time.
        private func placeLine(_ info: SocialContentInfo?, _ palette: SocialPalette) -> some View {
            HStack(spacing: SocialSpacing.layer2) {
                if let community = info?.communityName, info?.isComment == false {
                    AvatarView(url: info?.communityIcon, size: .mini, kind: .community)
                    Text(verbatim: community)
                        .font(.footnote)
                        .foregroundStyle(palette.foreground)
                        .onTapGesture { actions.openCommunity?(target) }
                    Text(verbatim: "•").font(.footnote).foregroundStyle(palette.foreground.opacity(0.5))
                    Text(verbatim: info?.authorName ?? "")
                        .font(.footnote)
                        .foregroundStyle(palette.foreground.opacity(0.5))
                        .onTapGesture { openAuthor() }
                } else {
                    AvatarView(url: info?.authorAvatar, size: .mini, ring: ring(info, palette))
                    Text(verbatim: info?.authorName ?? "")
                        .font(.footnote.bold())
                        .foregroundStyle(palette.foreground)
                        .onTapGesture { openAuthor() }
                }
                Text(verbatim: "•").font(.footnote).foregroundStyle(palette.foreground.opacity(0.5))
                time(info, palette, font: .caption)
            }
            .lineLimit(1)
        }

        @ViewBuilder
        private func time(_ info: SocialContentInfo?, _ palette: SocialPalette, font: Font) -> some View {
            HStack(alignment: .lastTextBaseline, spacing: SocialSpacing.layer1) {
                if info?.isEdited == true {
                    Text("edited")
                        .font(.caption2.italic())
                }
                if let created = info?.created {
                    Text(verbatim: SocialFormat.relative(created))
                        .font(font)
                }
            }
            .foregroundStyle(palette.foreground.opacity(0.5))
            .lineLimit(1)
            .fixedSize()
        }

        private func ring(_ info: SocialContentInfo?, _ palette: SocialPalette) -> Color {
            if info?.authorIsAdmin == true { return palette.admin }
            if info?.authorIsOriginalPoster == true { return palette.originalPoster }
            return .clear
        }

        private func openAuthor() {
            actions.openUser?(target)
        }
    }

    #Preview {
        VStack(spacing: SocialSpacing.layer4) {
            ForEach(SocialStyle.allCases) { style in
                ContentHeaderView(target: .post(SocialSample.posts[0]), actions: .sample)
                    .socialStyle(style)
            }
        }
        .padding()
    }
    """##
}
