//  WHAT: The template of `LinkPreviewView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let linkPreviewView = ##"""
    import LinkPresentation
    import SwiftUI
    import UniformTypeIdentifiers

    /// A card for a shared link: its picture, its title and its site. What the post says of the link is shown at once;
    /// when it says nothing at all, the page's own title and picture are fetched while the card shows.
    struct LinkPreviewView: View {
        var url: URL
        var title: String? = nil
        var image: URL? = nil
        /// A small card beside text, with the picture as a thumbnail.
        var isCompact = false
        /// Opens the link; the system opens it when this is left out.
        var open: (@MainActor (URL) -> Void)? = nil

        @Environment(\.socialStyle) private var style
        @Environment(\.openURL) private var openURL
        @State private var fetched: SocialLinkMetadata?

        var body: some View {
            let palette = style.palette
            let shownTitle = title ?? fetched?.title
            Button {
                if let open { open(url) } else { openURL(url) }
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    if !isCompact { picture(palette) }
                    HStack(spacing: SocialSpacing.layer2) {
                        VStack(alignment: .leading, spacing: 0) {
                            if let shownTitle {
                                Text(verbatim: shownTitle)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(palette.foreground)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                            }
                            Text(verbatim: url.host() ?? url.absoluteString)
                                .font(.footnote)
                                .foregroundStyle(palette.secondaryForeground)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                        if isCompact, image != nil || fetched?.image != nil {
                            picture(palette)
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        } else if image == nil, fetched?.image == nil {
                            Image(systemName: "arrow.up.forward.app.fill")
                                .font(.title2)
                                .foregroundStyle(palette.secondaryForeground)
                        }
                    }
                    .padding(.horizontal, SocialSpacing.layer3)
                    .padding(.vertical, SocialSpacing.layer2)
                    .background(palette.secondaryBackground)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(LinkPressStyle())
            .accessibilityLabel(Text("Open \(shownTitle ?? url.host() ?? url.absoluteString)"))
            .task(id: url) {
                // Only a link the post says nothing of is fetched: there is no cache, so a card fetches each time it shows.
                guard title == nil, image == nil, fetched == nil else { return }
                fetched = await SocialLinkMetadata.load(url)
            }
        }

        @ViewBuilder
        private func picture(_ palette: SocialPalette) -> some View {
            if let image {
                AsyncImage(url: image) { phase in
                    if let loaded = phase.image {
                        loaded.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        palette.tertiaryBackground
                    }
                }
                .frame(maxWidth: .infinity, minHeight: isCompact ? 32 : 160, maxHeight: isCompact ? 32 : 220)
                .clipped()
            } else if let fetchedImage = fetched?.image {
                fetchedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, minHeight: isCompact ? 32 : 160, maxHeight: isCompact ? 32 : 220)
                    .clipped()
            }
        }
    }

    /// A link's title and picture, as the page itself says them.
    struct SocialLinkMetadata: Sendable {
        var title: String?
        var imageData: Data?

        var image: Image? {
            guard let imageData else { return nil }
            #if os(iOS)
            return UIImage(data: imageData).map { Image(uiImage: $0) }
            #else
            return NSImage(data: imageData).map { Image(nsImage: $0) }
            #endif
        }

        /// Fetches what `url`'s page says of itself; nil when it cannot be read.
        @MainActor
        static func load(_ url: URL) async -> SocialLinkMetadata? {
            let provider = LPMetadataProvider()
            provider.shouldFetchSubresources = false
            guard let metadata = try? await provider.startFetchingMetadata(for: url) else { return nil }
            let title = metadata.title
            guard let imageProvider = metadata.imageProvider else { return SocialLinkMetadata(title: title) }
            let data: Data? = await withCheckedContinuation { continuation in
                _ = imageProvider.loadDataRepresentation(for: .image) { data, _ in continuation.resume(returning: data) }
            }
            return SocialLinkMetadata(title: title, imageData: data)
        }
    }

    /// Loom's press: a link card shrinks a little under the finger.
    private struct LinkPressStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .opacity(configuration.isPressed ? 0.9 : 1)
                .animation(.spring(), value: configuration.isPressed)
        }
    }

    #Preview {
        VStack {
            if let url = SocialSample.posts[1].socialURL {
                LinkPreviewView(url: url, title: "Sourdough starters, explained")
                LinkPreviewView(url: url, title: "Sourdough starters, explained", isCompact: true)
            }
        }
        .padding()
    }
    """##
}
