//  WHAT: The template of `SocialContext.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialContext = ##"""
    import SwiftUI

    /// Where content is shown, so a card can fit it: a feed, a post's page, a thread, search results, a profile, or an
    /// image to share. Set it with `.socialContext(_:)`; a card in a feed is the default.
    enum SocialContext: Hashable, Sendable {
        case feed
        case post
        case thread
        case search
        case profile
        case share

        /// Whether a card offers its menu and its actions: not on an image to share.
        var isInteractive: Bool { self != .share }

        /// Whether a card is cut short, as search results show many side by side.
        var isPreview: Bool { self == .search }
    }

    private struct SocialContextKey: EnvironmentKey {
        static let defaultValue: SocialContext = .feed
    }

    extension EnvironmentValues {
        /// Where the content below is shown.
        var socialContext: SocialContext {
            get { self[SocialContextKey.self] }
            set { self[SocialContextKey.self] = newValue }
        }
    }

    extension View {
        /// Shows the content below as it fits `context`.
        func socialContext(_ context: SocialContext) -> some View {
            environment(\.socialContext, context)
        }
    }
    """##
}
