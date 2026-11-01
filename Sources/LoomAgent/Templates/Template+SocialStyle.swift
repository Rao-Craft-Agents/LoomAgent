//  WHAT: The template of `SocialStyle.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialStyle = ##"""
    import SwiftUI

    /// The look of the social views. Every view reads it from the environment, so one `.socialStyle(_:)` high in the
    /// app restyles them all, and a settings picker can offer `SocialStyle.allCases`.
    enum SocialStyle: String, CaseIterable, Identifiable, Hashable, Sendable {
        /// Loom's look: an avatar column with a thread line, its spacing and its colours.
        case loom
        /// A timeline: an avatar column, content edge to edge, counts beside the actions.
        case social
        /// A compact list with thumbnails and scores, as a link aggregator reads.
        case reader

        var id: Self { self }

        /// The name a settings picker shows.
        var title: LocalizedStringKey {
            switch self {
            case .loom: return "Loom"
            case .social: return "Social"
            case .reader: return "Reader"
            }
        }

        /// The colours it paints with.
        var palette: SocialPalette {
    //@if colors.code
            self == .loom ? .loom : .system
    //@else
            .assets
    //@endif
        }

        /// Whether a card hangs its content off an avatar column; a reader row puts the place and time on one line.
        var usesAvatarColumn: Bool { self != .reader }

        /// Whether a line runs down from the avatar of content that has replies, as Loom draws it.
        var drawsThreadLine: Bool { self == .loom }

        /// The space above and below a card in a feed.
        var cardPadding: CGFloat {
            switch self {
            case .loom: return SocialSpacing.layer6
            case .social: return SocialSpacing.layer4
            case .reader: return SocialSpacing.layer3
            }
        }
    }

    /// The colour roles the social views paint with.
    struct SocialPalette: Sendable {
        var background: Color
        var alternateBackground: Color
        var secondaryBackground: Color
        var tertiaryBackground: Color
        var foreground: Color
        var secondaryForeground: Color
        var accent: Color
        var upvote: Color
        var downvote: Color
        /// The ring around a comment's author when they wrote the post too.
        var originalPoster: Color
        /// The ring around an administrator.
        var admin: Color
        var pinned: Color
        var locked: Color
        /// The chips that hold a post count and a comment count.
        var stat: Color
        /// What a swipe to reply reveals.
        var swipe: Color
        /// A button that connects, and the same button once connected.
        var connect: Color
        var connected: Color
    }

    extension SocialPalette {
    //@if colors.code
        /// Loom's colours, for light and dark.
        static let loom = SocialPalette(
            background: .socialDynamic(light: 0xFFFFFF, dark: 0x121212),
            alternateBackground: .socialDynamic(light: 0xFFFFFF, dark: 0x090909),
            secondaryBackground: .socialDynamic(light: 0xECEFF1, dark: 0x1A1A1A),
            tertiaryBackground: .socialDynamic(light: 0xCFD8DC, dark: 0x282828),
            foreground: .socialDynamic(light: 0x121212, dark: 0xF5F5F5),
            secondaryForeground: .socialDynamic(light: 0x3C3C43, dark: 0xEBEBF5, opacity: 0.6),
            accent: .accentColor,
            upvote: .orange,
            downvote: .blue,
            originalPoster: .blue.opacity(0.8),
            admin: .red.opacity(0.8),
            pinned: .green.opacity(0.8),
            locked: .yellow.opacity(0.8),
            stat: Color(red: 1, green: 0.694, blue: 0.314).opacity(0.9),
            swipe: Color(red: 0.537, green: 0.812, blue: 0.941),
            connect: Color(red: 1, green: 0.804, blue: 0),
            connected: Color(red: 0.925, green: 0.424, blue: 1))

        /// The system's colours, which follow the person's appearance and contrast settings.
        static let system = SocialPalette(
            background: .socialSystem(.background),
            alternateBackground: .socialSystem(.background),
            secondaryBackground: .socialSystem(.secondaryBackground),
            tertiaryBackground: .socialSystem(.tertiaryBackground),
            foreground: .primary,
            secondaryForeground: .secondary,
            accent: .accentColor,
            upvote: .orange,
            downvote: .blue,
            originalPoster: .blue.opacity(0.8),
            admin: .red.opacity(0.8),
            pinned: .green,
            locked: .yellow,
            stat: .orange.opacity(0.8),
            swipe: .accentColor,
            connect: .accentColor,
            connected: .purple)
    //@else
        /// The app's colours, read from its asset catalog by name.
        static let assets = SocialPalette(
            background: Color("colors/background"),
            alternateBackground: Color("colors/alternateBackground"),
            secondaryBackground: Color("colors/secondaryBackground"),
            tertiaryBackground: Color("colors/tertiaryBackground"),
            foreground: Color("colors/foreground"),
            secondaryForeground: Color("colors/secondaryForeground"),
            accent: .accentColor,
            upvote: .orange,
            downvote: .blue,
            originalPoster: .blue.opacity(0.8),
            admin: .red.opacity(0.8),
            pinned: .green.opacity(0.8),
            locked: .yellow.opacity(0.8),
            stat: .orange.opacity(0.8),
            swipe: .accentColor,
            connect: .accentColor,
            connected: .purple)
    //@endif
    }

    /// Loom's spacing layers: 4, 8, 12, 16, 24 and 32 points.
    enum SocialSpacing {
        static let layer1: CGFloat = 4
        static let layer2: CGFloat = 8
        static let layer3: CGFloat = 12
        static let layer4: CGFloat = 16
        static let layer5: CGFloat = 24
        static let layer6: CGFloat = 32
    }

    //@if colors.code
    extension Color {
        /// `light` in light mode and `dark` in dark mode, each `0xRRGGBB`.
        static func socialDynamic(light: UInt32, dark: UInt32, opacity: Double = 1) -> Color {
            #if os(iOS)
            return Color(uiColor: UIColor { traits in
                let hex = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                               blue: CGFloat(hex & 0xFF) / 255, alpha: opacity)
            })
            #else
            return Color(nsColor: NSColor(name: nil) { appearance in
                let hex = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
                return NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                               blue: CGFloat(hex & 0xFF) / 255, alpha: opacity)
            })
            #endif
        }

        /// A background the system defines, on either platform.
        enum SocialSystemBackground { case background, secondaryBackground, tertiaryBackground }

        static func socialSystem(_ role: SocialSystemBackground) -> Color {
            #if os(iOS)
            switch role {
            case .background: return Color(uiColor: .systemBackground)
            case .secondaryBackground: return Color(uiColor: .secondarySystemBackground)
            case .tertiaryBackground: return Color(uiColor: .systemGray5)
            }
            #else
            switch role {
            case .background: return Color(nsColor: .textBackgroundColor)
            case .secondaryBackground: return Color(nsColor: .windowBackgroundColor)
            case .tertiaryBackground: return Color(nsColor: .quaternaryLabelColor)
            }
            #endif
        }
    }

    //@endif
    private struct SocialStyleKey: EnvironmentKey {
    //@if style.loom
        static let defaultValue: SocialStyle = .loom
    //@endif
    //@if style.social
        static let defaultValue: SocialStyle = .social
    //@endif
    //@if style.reader
        static let defaultValue: SocialStyle = .reader
    //@endif
    }

    extension EnvironmentValues {
        /// The look of the social views below.
        var socialStyle: SocialStyle {
            get { self[SocialStyleKey.self] }
            set { self[SocialStyleKey.self] = newValue }
        }
    }

    extension View {
        /// Shows the social views below in `style`.
        func socialStyle(_ style: SocialStyle) -> some View {
            environment(\.socialStyle, style)
        }
    }
    """##
}
