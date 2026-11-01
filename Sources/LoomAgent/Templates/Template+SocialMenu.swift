//  WHAT: The template of `SocialMenu.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialMenu = ##"""
    import SwiftUI

    /// A choice a list offers above itself: how a feed is sorted, which posts it lists, how comments are ordered. The
    /// app owns the value; the menu shows its options and sets it.
    ///
    ///     SocialMenu("Sort", selection: $sort, options: FeedSort.allCases, title: \.title, systemImage: \.symbol)
    struct SocialMenu {
        struct Option {
            let title: LocalizedStringKey
            let systemImage: String?
        }

        /// What the menu chooses, for VoiceOver.
        let label: LocalizedStringKey
        let options: [Option]
        let selected: Int
        let select: (Int) -> Void

        init<Value: Hashable>(_ label: LocalizedStringKey, selection: Binding<Value>, options: [Value],
                              title: (Value) -> LocalizedStringKey, systemImage: (Value) -> String? = { _ in nil }) {
            self.label = label
            self.options = options.map { Option(title: title($0), systemImage: systemImage($0)) }
            self.selected = options.firstIndex(of: selection.wrappedValue) ?? 0
            self.select = { index in
                guard options.indices.contains(index) else { return }
                selection.wrappedValue = options[index]
            }
        }

        /// The option chosen now.
        var current: Option? { options.indices.contains(selected) ? options[selected] : nil }
    }

    /// One menu as Loom draws it: the chosen option in the accent colour, and on iPhone and iPad a chevron that says
    /// it opens.
    struct SocialMenuButton: View {
        var menu: SocialMenu

        @Environment(\.socialStyle) private var style

        var body: some View {
            Menu {
                ForEach(menu.options.indices, id: \.self) { index in
                    let option = menu.options[index]
                    Button { menu.select(index) } label: {
                        if let symbol = option.systemImage {
                            Label(option.title, systemImage: symbol)
                        } else {
                            Text(option.title)
                        }
                    }
                }
            } label: {
                HStack(spacing: SocialSpacing.layer1) {
                    if let current = menu.current { Text(current.title) }
                    #if os(iOS)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                    #endif
                }
                .foregroundStyle(style.palette.accent)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .fixedSize()
            .accessibilityLabel(Text(menu.label))
        }
    }

    private struct SocialMenuPreview: View {
        @State private var sort = "Hot"

        var body: some View {
            SocialMenuButton(menu: SocialMenu("Sort", selection: $sort, options: ["Hot", "New", "Top"], title: { LocalizedStringKey($0) }))
                .padding()
        }
    }

    #Preview {
        SocialMenuPreview()
    }
    """##
}
