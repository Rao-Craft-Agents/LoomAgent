//  WHAT: The template of `MediaGalleryView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let mediaGalleryView = ##"""
    import SwiftUI

    /// A post's pictures: one fills the card's width; several page sideways with a count of where you are. A tap
    /// opens the picture with the app, or with the system when the app does not say.
    struct MediaGalleryView: View {
        var urls: [URL]
        var maxHeight: CGFloat = 320
        var open: (@MainActor (URL) -> Void)? = nil

        @Environment(\.socialStyle) private var style
        @Environment(\.openURL) private var openURL
        @State private var page: Int? = 0

        var body: some View {
            if urls.count == 1, let url = urls.first {
                picture(url)
            } else if !urls.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: SocialSpacing.layer2) {
                        ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                            picture(url)
                                .containerRelativeFrame(.horizontal)
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $page)
                .frame(height: maxHeight)
                .overlay(alignment: .topTrailing) {
                    Text("\((page ?? 0) + 1) of \(urls.count)")
                        .font(.caption.monospacedDigit())
                        .padding(.horizontal, SocialSpacing.layer2)
                        .padding(.vertical, SocialSpacing.layer1)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(SocialSpacing.layer2)
                }
            }
        }

        private func picture(_ url: URL) -> some View {
            let palette = style.palette
            return Button {
                if let open { open(url) } else { openURL(url) }
            } label: {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .font(.title3)
                            .foregroundStyle(palette.secondaryForeground)
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 160, maxHeight: maxHeight)
                .background(palette.tertiaryBackground.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Picture"))
        }
    }

    /// A small square picture beside a reader row's title.
    struct MediaThumbnailView: View {
        var url: URL
        var side: CGFloat = 60

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(palette.foreground)
                }
            }
            .frame(width: side, height: side)
            .background(palette.foreground.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityHidden(true)
        }
    }

    #Preview {
        VStack {
            MediaGalleryView(urls: [URL(fileURLWithPath: "/sample/one.jpg"), URL(fileURLWithPath: "/sample/two.jpg")])
            MediaThumbnailView(url: URL(fileURLWithPath: "/sample/one.jpg"))
        }
        .padding()
    }
    """##
}
