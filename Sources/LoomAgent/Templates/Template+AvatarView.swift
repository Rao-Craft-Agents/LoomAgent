//  WHAT: The template of `AvatarView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let avatarView = ##"""
    import SwiftUI

    /// A round picture of a person or a community, with a symbol while it loads or when there is none, and a ring
    /// that marks an administrator or a post's own author.
    struct AvatarView: View {
        enum Size: Sendable {
            case large, medium, small, mini

            var points: CGFloat {
                switch self {
                case .large: return 64
                case .medium: return 48
                case .small: return 40
                case .mini: return 32
                }
            }

            var symbolFont: Font {
                switch self {
                case .large: return .title
                case .medium: return .title2
                case .small: return .title3
                case .mini: return .footnote
                }
            }
        }

        enum Kind: Sendable { case person, community }

        var url: URL?
        var size: Size = .small
        var kind: Kind = .person
        var ring: Color = .clear

        @Environment(\.socialStyle) private var style
        @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

        var body: some View {
            let palette = style.palette
            let side = size.points * scale
            ZStack {
                Circle().fill(palette.tertiaryBackground)
                if let url {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            symbol(palette)
                        }
                    }
                } else {
                    symbol(palette)
                }
            }
            .frame(width: side, height: side)
            .clipShape(Circle())
            .overlay(Circle().stroke(ring, lineWidth: 1))
            .accessibilityHidden(true)
        }

        private func symbol(_ palette: SocialPalette) -> some View {
            Image(systemName: kind == .community ? "person.3" : "person")
                .font(kind == .community && size != .large ? .caption : size.symbolFont)
                .foregroundStyle(palette.foreground)
                .offset(y: -1)
        }
    }

    #Preview {
        HStack(spacing: SocialSpacing.layer3) {
            AvatarView(size: .large)
            AvatarView(size: .medium, ring: .blue.opacity(0.8))
            AvatarView(size: .small, kind: .community)
            AvatarView(size: .mini)
        }
        .padding()
    }
    """##
}
