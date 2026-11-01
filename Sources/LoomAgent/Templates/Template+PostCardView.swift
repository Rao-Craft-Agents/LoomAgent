//  WHAT: The template of `PostCardView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let postCardView = ##"""
    import SwiftUI

    /// A post as a feed shows it. Loom's card hangs it off the author's avatar, with a line running down when it has
    /// comments: the author and the time, the title, the start of its body with a way to read more, its link or
    /// pictures, then its votes and counts. A timeline keeps the avatar column and puts counts beside their buttons;
    /// a reader row leads with the community and puts a thumbnail beside the title. Content marked not safe for work
    /// stays hidden until tapped; removed and deleted posts say so.
    struct PostCardView<Social: SocialSchema>: View {
        var post: Social.Post
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        @Environment(\.socialContext) private var context
        @Environment(\.openURL) private var openURL
    //@if nsfwShield
        @State private var revealed = false
    //@endif

        var body: some View {
            let palette = style.palette
            let info = SocialContentInfo(post)
            Group {
                if style.usesAvatarColumn {
                    HStack(alignment: .top, spacing: SocialSpacing.layer3) {
                        avatarColumn(info, palette)
                        VStack(alignment: .leading, spacing: SocialSpacing.layer1) {
                            ContentHeaderView(target: .post(post), actions: actions)
                            content(info, palette)
                            if !info.isRemoved {
                                ContentFooterView(target: .post(post), actions: actions)
                            }
                        }
                    }
                    // The column is as tall as the post, so its thread line reaches the counts.
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                        ContentHeaderView(target: .post(post), actions: actions)
                        content(info, palette)
                        if !info.isRemoved {
                            ContentFooterView(target: .post(post), actions: actions)
                        }
                    }
                }
            }
            .padding(.horizontal, SocialSpacing.layer4)
            .padding(.vertical, context == .share ? SocialSpacing.layer4 : style.cardPadding)
            .background(palette.background)
    #if os(macOS)
            .contextMenu {
                if context.isInteractive { ContentMenuItems(target: .post(post), actions: actions) }
            }
    #endif
        }

        // MARK: Parts

        /// The author's picture and, in Loom's look, a line down to the counts while the post has comments.
        private func avatarColumn(_ info: SocialContentInfo, _ palette: SocialPalette) -> some View {
            VStack(spacing: SocialSpacing.layer3) {
                AvatarView(url: info.authorAvatar, size: .small, ring: info.authorIsAdmin ? palette.admin : .clear)
                    .onTapGesture { actions.openUser?(.post(post)) }
                if style.drawsThreadLine, info.replies > 0 {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(palette.foreground.opacity(0.3))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .contentShape(Rectangle().inset(by: -8))
                        .onTapGesture { actions.openPost?(post) }
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
            if let reason = censorReason(info) {
                CensorView(reason: reason, reveal: reveal(reason))
                    .padding(.vertical, SocialSpacing.layer2)
            } else if style == .reader {
                HStack(alignment: .top, spacing: SocialSpacing.layer3) {
                    openable { text(info, palette) }
    //@if media
                    if let thumbnail = post.socialThumbnail ?? post.socialMedia.first {
                        MediaThumbnailView(url: thumbnail)
                            .onTapGesture { open(thumbnail) }
                    }
    //@endif
                }
                .padding(.bottom, SocialSpacing.layer2)
            } else {
                openable { text(info, palette) }
                attachment(palette)
            }
        }

        /// The title, and the start of the body with a way to read more (the whole body on its page).
        private func text(_ info: SocialContentInfo, _ palette: SocialPalette) -> some View {
            VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                if !post.socialTitle.isEmpty {
                    Text(verbatim: post.socialTitle)
                        .font(style == .reader ? .body.weight(.medium) : .body)
                        .foregroundStyle(palette.foreground.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let body = post.socialBody, !body.isEmpty {
                    if post.socialTitle.isEmpty {
                        // A post without a title (a status on a timeline): its text is the post, shown whole.
                        MarkdownBodyView(text: body, font: style == .reader ? .subheadline : .body,
                                         lineLimit: context.isPreview ? 4 : nil)
                    } else if post.socialURL == nil {
                        preview(body, palette)
                    }
                }
            }
            .padding(.bottom, style == .loom && post.socialURL == nil && post.socialMedia.isEmpty ? SocialSpacing.layer5 : SocialSpacing.layer2)
        }

        /// The first lines of the body; Loom ends a long one with *Read more*.
        @ViewBuilder
        private func preview(_ body: String, _ palette: SocialPalette) -> some View {
            let flat = body.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            if style == .loom && !context.isPreview {
                Text(readMore(flat, palette))
                    .font(.footnote)
                    .foregroundStyle(palette.foreground.opacity(0.9))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(verbatim: flat)
                    .font(.footnote)
                    .foregroundStyle(palette.secondaryForeground)
                    .lineLimit(context.isPreview ? 2 : 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }

        private func readMore(_ text: String, _ palette: SocialPalette) -> AttributedString {
            guard text.count > 120 else { return Self.styled(text) }
            var shown = Self.styled(String(text.prefix(120)).trimmingCharacters(in: .whitespaces) + "… ")
            var more = AttributedString(localized: "Read more")
            more.font = .footnote.italic()
            more.foregroundColor = palette.secondaryForeground
            shown.append(more)
            return shown
        }

    //@if markdown
        /// `text` with its inline Markdown (emphasis, code, links) styled.
        private static func styled(_ text: String) -> AttributedString {
            MarkdownBodyView.inline(text)
        }
    //@else
        /// `text` as it is.
        private static func styled(_ text: String) -> AttributedString {
            AttributedString(text)
        }
    //@endif

        /// What the post shares: its pictures, else its link.
        @ViewBuilder
        private func attachment(_ palette: SocialPalette) -> some View {
            let pictures = post.socialMedia.isEmpty ? (post.socialURL.map { Self.isPicture($0) ? [$0] : [] } ?? []) : post.socialMedia
    //@if media
            if !pictures.isEmpty {
                MediaGalleryView(urls: pictures, open: actions.openLink)
                    .padding(.top, SocialSpacing.layer2)
                    .padding(.bottom, style == .loom ? SocialSpacing.layer5 : SocialSpacing.layer3)
            } else if let url = post.socialURL {
                link(url, palette)
            }
    //@else
            if let url = post.socialURL ?? pictures.first {
                link(url, palette)
            }
    //@endif
        }

        @ViewBuilder
        private func link(_ url: URL, _ palette: SocialPalette) -> some View {
    //@if linkPreview
            LinkPreviewView(url: url, title: post.socialLinkTitle, image: post.socialThumbnail, isCompact: context.isPreview, open: actions.openLink)
                .frame(maxWidth: 500, alignment: .leading)
                .padding(.top, SocialSpacing.layer2)
                .padding(.bottom, style == .loom ? SocialSpacing.layer5 : SocialSpacing.layer3)
    //@else
            Button { open(url) } label: {
                Label { Text(verbatim: url.host() ?? url.absoluteString) } icon: { Image(systemName: "link") }
                    .font(.footnote)
                    .foregroundStyle(palette.accent)
            }
            .buttonStyle(.plain)
            .padding(.bottom, style == .loom ? SocialSpacing.layer5 : SocialSpacing.layer3)
    //@endif
        }

        /// The title and body as one button to the post's page, when the card is not on it.
        @ViewBuilder
        private func openable<Label: View>(@ViewBuilder _ label: () -> Label) -> some View {
            if context != .post, context.isInteractive, let openPost = actions.openPost {
                Button { openPost(post) } label: { label().contentShape(Rectangle()) }
                    .buttonStyle(.plain)
            } else {
                label()
            }
        }

        // MARK: Hiding

        private func censorReason(_ info: SocialContentInfo) -> CensorView.Reason? {
            if info.isRemoved { return .removed }
            if info.isDeleted { return .deleted }
    //@if nsfwShield
            if info.isNSFW, !revealed { return .nsfw }
    //@endif
            return nil
        }

        private func reveal(_ reason: CensorView.Reason) -> (() -> Void)? {
    //@if nsfwShield
            guard reason == .nsfw else { return nil }
            return { withAnimation { revealed = true } }
    //@else
            nil
    //@endif
        }

        private func open(_ url: URL) {
            if let openLink = actions.openLink { openLink(url) } else { openURL(url) }
        }

        /// Whether a link points at a picture rather than a page.
        static func isPicture(_ url: URL) -> Bool {
            ["jpg", "jpeg", "png", "gif", "webp", "heic"].contains(url.pathExtension.lowercased())
        }
    }

    #Preview("Loom") {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(SocialSample.posts) { post in
                    PostCardView(post: post, actions: .sample)
                    Divider()
                }
            }
        }
    }

    #Preview("Reader") {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(SocialSample.posts) { post in
                    PostCardView(post: post, actions: .sample)
                    Divider()
                }
            }
        }
        .socialStyle(.reader)
    }
    """##
}
