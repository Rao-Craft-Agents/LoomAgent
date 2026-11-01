//  WHAT: The template of `PostPageView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let postPageView = ##"""
    import SwiftUI

    /// A post's own page: its author, its title, what it shares, its whole body, its votes with a reply button, then
    /// how the comments are ordered and the thread itself. Pull to refresh asks for the post and its comments again.
    struct PostPageView<Social: SocialSchema>: View {
        var post: Social.Post
        var comments: [Social.Comment]
        var phase: SocialPhase = .idle
        /// How the comments are ordered, when the app offers a choice.
        var sort: SocialMenu? = nil
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        @Environment(\.openURL) private var openURL
    //@if nsfwShield
        @State private var revealed = false
    //@endif

        var body: some View {
            let palette = style.palette
            let info = SocialContentInfo(post)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: SocialSpacing.layer2) {
                        if style.usesAvatarColumn {
                            AvatarView(url: info.authorAvatar, size: .small, ring: info.authorIsAdmin ? palette.admin : .clear)
                                .onTapGesture { actions.openUser?(.post(post)) }
                        }
                        ContentHeaderView(target: .post(post), actions: actions)
                    }
                    .padding(.horizontal, SocialSpacing.layer4)
                    .padding(.top, SocialSpacing.layer3)

                    if !post.socialTitle.isEmpty {
                        Text(verbatim: post.socialTitle)
                            .font(.title3.bold())
                            .foregroundStyle(palette.foreground.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, SocialSpacing.layer4)
                            .padding(.vertical, SocialSpacing.layer3)
                    }

                    content(info, palette)
                        .padding(.horizontal, SocialSpacing.layer4)

                    ContentFooterView(target: .post(post), actions: actions, isHeader: true)
                        .socialStyle(style == .loom ? .reader : style)
                        .padding(.horizontal, SocialSpacing.layer4)
                        .padding(.top, SocialSpacing.layer5)
                        .padding(.bottom, SocialSpacing.layer5)

                    Divider()

                    if let sort {
                        HStack {
                            SocialMenuButton(menu: sort)
                            Spacer()
                        }
                        .padding(SocialSpacing.layer4)
                        Divider()
                    }

                    CommentThreadView(comments: comments, phase: phase, actions: actions)
                        .background(palette.alternateBackground)
                }
            }
            .socialRefreshable(actions.refresh)
            .background(palette.background)
            .socialContext(.post)
        }

        @ViewBuilder
        private func content(_ info: SocialContentInfo, _ palette: SocialPalette) -> some View {
            if info.isRemoved {
                CensorView(reason: .removed)
            } else if info.isDeleted {
                CensorView(reason: .deleted)
    //@if nsfwShield
            } else if info.isNSFW, !revealed {
                CensorView(reason: .nsfw) { withAnimation { revealed = true } }
    //@endif
            } else {
                VStack(alignment: .leading, spacing: SocialSpacing.layer4) {
    //@if media
                    let pictures = post.socialMedia.isEmpty ? (post.socialURL.map { PostCardView<Social>.isPicture($0) ? [$0] : [] } ?? []) : post.socialMedia
                    if !pictures.isEmpty {
                        MediaGalleryView(urls: pictures, maxHeight: 420, open: actions.openLink)
                    } else if let url = post.socialURL {
                        link(url, palette)
                    }
    //@else
                    if let url = post.socialURL {
                        link(url, palette)
                    }
    //@endif
                    if let body = post.socialBody, !body.isEmpty {
                        MarkdownBodyView(text: body)
                    }
                }
            }
        }

        @ViewBuilder
        private func link(_ url: URL, _ palette: SocialPalette) -> some View {
    //@if linkPreview
            LinkPreviewView(url: url, title: post.socialLinkTitle, image: post.socialThumbnail,
                            isCompact: post.socialBody?.isEmpty == false, open: actions.openLink)
                .frame(maxWidth: 400, alignment: .leading)
    //@else
            Button {
                if let openLink = actions.openLink { openLink(url) } else { openURL(url) }
            } label: {
                Label { Text(verbatim: url.host() ?? url.absoluteString) } icon: { Image(systemName: "link") }
                    .font(.subheadline)
                    .foregroundStyle(palette.accent)
            }
            .buttonStyle(.plain)
    //@endif
        }
    }

    private struct PostPagePreview: View {
        @State private var sort = "Top"

        var body: some View {
            PostPageView(post: SocialSample.posts[0], comments: SocialSample.comments, phase: .exhausted,
                         sort: SocialMenu("Sort comments", selection: $sort, options: ["Top", "New", "Old"], title: { LocalizedStringKey($0) }),
                         actions: .sample)
        }
    }

    #Preview {
        PostPagePreview()
    }
    """##
}
