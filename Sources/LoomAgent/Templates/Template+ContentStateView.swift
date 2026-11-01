//  WHAT: The template of `ContentStateView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let contentStateView = ##"""
    import SwiftUI

    /// What a list shows instead of content: a spinner while the first page loads, what is empty when nothing came,
    /// the error and a way to try again when the ask failed. At a list's end, a spinner while more loads and a retry
    /// when that failed.
    struct ContentStateView: View {
        var phase: SocialPhase
        /// What an empty list says: `No posts`.
        var empty: LocalizedStringKey
        /// Asks again: the retry button's action.
        var retry: (@MainActor () async -> Void)? = nil
        /// Sits at the end of a list that has content.
        var isFooter = false

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            VStack(spacing: SocialSpacing.layer3) {
                switch phase {
                case .loading:
                    ProgressView()
                        #if os(macOS)
                        .controlSize(.small)
                        #endif
                case .failed(let message):
                    if !isFooter {
                        Text(verbatim: message)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryForeground)
                            .multilineTextAlignment(.center)
                    }
                    retryButton(palette)
                case .idle, .exhausted:
                    if !isFooter {
                        Text(empty)
                            .font(.headline.bold())
                            .foregroundStyle(palette.foreground)
                        retryButton(palette)
                    }
                }
            }
            .padding(.vertical, SocialSpacing.layer3)
            .frame(maxWidth: .infinity, minHeight: isFooter ? 60 : 200)
        }

        @ViewBuilder
        private func retryButton(_ palette: SocialPalette) -> some View {
            if let retry {
                Button {
                    Task { await retry() }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline.bold())
                        .foregroundStyle(palette.foreground)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Try again"))
            }
        }
    }

    #Preview {
        VStack {
            ContentStateView(phase: .idle, empty: "No posts", retry: {})
            ContentStateView(phase: .failed("The server did not answer."), empty: "No posts", retry: {})
            ContentStateView(phase: .loading, empty: "No posts", isFooter: true)
        }
    }
    """##
}
