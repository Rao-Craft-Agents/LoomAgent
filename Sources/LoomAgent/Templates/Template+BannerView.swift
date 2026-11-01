//  WHAT: The template of `BannerView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let bannerView = ##"""
    import SwiftUI

    /// The wide picture across the top of a profile, a community or an instance.
    struct BannerView: View {
        var url: URL?
        var height: CGFloat = 120

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            Rectangle()
                .fill(palette.secondaryBackground)
                .overlay {
                    if let url {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Image(systemName: "photo")
                                    .font(.title3)
                                    .foregroundStyle(palette.secondaryForeground)
                            }
                        }
                    }
                }
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()
                .accessibilityHidden(true)
        }
    }

    #Preview {
        BannerView(url: nil)
    }
    """##
}
