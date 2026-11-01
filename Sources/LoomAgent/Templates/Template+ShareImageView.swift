//  WHAT: The template of `ShareImageView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let shareImageView = ##"""
    import SwiftUI

    /// A post or a comment shared as a picture, as Loom does it: the card drawn as it shows in a feed, without its
    /// buttons, and a share button for the picture beside one for the link.
    struct ShareImageView<Social: SocialSchema>: View {
        /// The post or the comment to share.
        var target: SocialTarget<Social>
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.displayScale) private var displayScale
        @State private var picture: Image?

        var body: some View {
            let palette = style.palette
            VStack(alignment: .leading, spacing: SocialSpacing.layer4) {
                Text("Share")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                ScrollView {
                    card
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(palette.foreground.opacity(0.15), lineWidth: 1))
                }
                HStack(spacing: SocialSpacing.layer5) {
                    Spacer()
                    if let picture {
                        ShareLink(item: picture, preview: SharePreview(Text("Shared from the app"), image: picture)) {
                            Label("Share image", systemImage: "photo")
                        }
                    } else {
                        ProgressView().controlSize(.small)
                    }
                    if let link = target.content?.permalink {
                        ShareLink(item: link) {
                            Label("Share link", systemImage: "link")
                        }
                    }
                    Spacer()
                }
                .font(.headline)
            }
            .foregroundStyle(palette.foreground)
            .padding(SocialSpacing.layer5)
            .background(palette.background)
            .task(id: colorScheme) { render() }
        }

        /// The card as the picture shows it: a feed's card, without its buttons.
        @ViewBuilder
        private var card: some View {
            Group {
                switch target {
                case .post(let post): PostCardView(post: post, actions: actions)
                case .comment(let comment): CommentCardView(comment: comment, actions: actions)
                case .user, .community, .instance: EmptyView()
                }
            }
            .socialContext(.share)
        }

        private func render() {
            let renderer = ImageRenderer(content: card
                .frame(width: 360)
                .socialStyle(style)
                .environment(\.colorScheme, colorScheme))
            renderer.scale = displayScale
            if let image = renderer.cgImage {
                picture = Image(decorative: image, scale: displayScale)
            }
        }
    }

    #Preview {
        ShareImageView(target: .post(SocialSample.posts[0]), actions: .sample)
    }
    """##
}
