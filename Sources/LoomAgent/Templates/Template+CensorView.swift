//  WHAT: The template of `CensorView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let censorView = ##"""
    import SwiftUI

    /// What stands in for content a person should not see as it is: marked not safe for work, written by a bot,
    /// removed by a moderator, deleted by its author, or by someone blocked. Content that may be shown is shown by a
    /// tap anywhere on it, as in Loom.
    struct CensorView: View {
        enum Reason: Sendable {
            case nsfw, bot, removed, deleted, blocked

            var symbol: String {
                switch self {
                case .nsfw: return "eye.slash.fill"
                case .bot: return "cpu"
                case .removed: return "exclamationmark.octagon"
                case .deleted: return "trash"
                case .blocked: return "exclamationmark.shield"
                }
            }

            var message: LocalizedStringKey {
                switch self {
                case .nsfw: return "This is meant for mature audiences."
                case .bot: return "This was posted by a bot."
                case .removed: return "Removed by moderators"
                case .deleted: return "Deleted"
                case .blocked: return "Blocked"
                }
            }

            /// Whether a tap may show what it hides: only content marked not safe for work or written by a bot.
            var canReveal: Bool { self == .nsfw || self == .bot }
        }

        var reason: Reason
        var isComment = false
        /// Shows what is hidden; when nil, the content stays hidden.
        var reveal: (() -> Void)?

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            VStack(spacing: SocialSpacing.layer4) {
                Image(systemName: reason.symbol)
                    .font(isComment ? .title3 : .title)
                Text(reason.message)
                    .font((isComment ? Font.footnote : Font.subheadline).bold())
                    .multilineTextAlignment(.center)
                if reason.canReveal, reveal != nil {
                    Text("Tap to show")
                        .font(isComment ? .caption : .footnote)
                        .foregroundStyle(palette.secondaryForeground)
                }
            }
            .padding(.horizontal, SocialSpacing.layer3)
            .foregroundStyle(palette.foreground)
            .frame(maxWidth: .infinity, minHeight: isComment ? 100 : 200)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .background(palette.tertiaryBackground.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
                if reason.canReveal { reveal?() }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(reason.canReveal && reveal != nil ? .isButton : [])
            .accessibilityHint(reason.canReveal && reveal != nil ? Text("Shows what is hidden") : Text(verbatim: ""))
        }
    }

    #Preview {
        VStack {
            CensorView(reason: .nsfw, reveal: {})
            CensorView(reason: .removed, isComment: true)
        }
        .padding()
    }
    """##
}
