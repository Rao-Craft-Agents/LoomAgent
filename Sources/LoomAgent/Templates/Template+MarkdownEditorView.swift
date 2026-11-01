//  WHAT: The template of `MarkdownEditorView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let markdownEditorView = ##"""
    import SwiftUI

    /// Where a post or a reply is written: a text editor with a placeholder, a row of Markdown shortcuts under it
    /// (bold, italic, a heading, a quote, code, a link, a list), and a preview of the result. Where the system lets
    /// the editor know the selection, a shortcut wraps the selected text; elsewhere it adds to the end.
    struct MarkdownEditorView: View {
        @Binding var text: String
        var placeholder: LocalizedStringKey = "Write something..."

        @Environment(\.socialStyle) private var style
    //@if markdown
        @State private var previewing = false
    //@endif

        var body: some View {
            let palette = style.palette
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
    //@if markdown
                    if previewing {
                        ScrollView {
                            MarkdownBodyView(text: text, font: .body)
                                .padding(SocialSpacing.layer3)
                        }
                    } else {
                        editor(palette)
                    }
    //@else
                    editor(palette)
    //@endif
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
    //@if markdown
                Divider()
                HStack(spacing: SocialSpacing.layer2) {
                    ForEach(MarkdownShortcut.allCases, id: \.self) { shortcut in
                        Button { apply(shortcut) } label: {
                            Image(systemName: shortcut.systemImage)
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 32, height: 32)
                                .background(palette.tertiaryBackground.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel(Text(shortcut.label))
                        .disabled(previewing)
                    }
                    Spacer(minLength: 0)
                    Button { previewing.toggle() } label: {
                        Image(systemName: previewing ? "eye.slash" : "eye")
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(previewing ? Text("Edit") : Text("Preview"))
                }
                .buttonStyle(.plain)
                .foregroundStyle(palette.foreground)
                .padding(.horizontal, SocialSpacing.layer3)
                .padding(.vertical, SocialSpacing.layer2)
    //@endif
            }
        }

        @ViewBuilder
        private func editor(_ palette: SocialPalette) -> some View {
            Group {
    //@if markdown
                if #available(iOS 18.0, macOS 15.0, *) {
                    SelectingEditor(text: $text, shortcut: $pending)
                } else {
                    TextEditor(text: $text)
                }
    //@else
                TextEditor(text: $text)
    //@endif
            }
            .font(style == .loom ? .title3.bold() : .body)
            .foregroundStyle(palette.foreground)
            .scrollContentBackground(.hidden)
            .padding(SocialSpacing.layer3)
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(style == .loom ? .title3.bold() : .body)
                        .foregroundStyle(palette.foreground.opacity(0.3))
                        .padding(.horizontal, SocialSpacing.layer4 + 2)
                        .padding(.vertical, SocialSpacing.layer3 + 8)
                        .allowsHitTesting(false)
                }
            }
        }

    //@if markdown

        /// A shortcut waiting for the editor that knows the selection to apply it.
        @State private var pending: MarkdownShortcut?

        private func apply(_ shortcut: MarkdownShortcut) {
            if #available(iOS 18.0, macOS 15.0, *) {
                pending = shortcut
            } else {
                text = shortcut.appending(to: text)
            }
        }
    //@endif
    }
    //@if markdown

    /// A Markdown shortcut of the editor's row.
    enum MarkdownShortcut: CaseIterable, Hashable, Sendable {
        case bold, italic, heading, quote, code, link, list

        var systemImage: String {
            switch self {
            case .bold: return "bold"
            case .italic: return "italic"
            case .heading: return "number"
            case .quote: return "text.quote"
            case .code: return "chevron.left.forwardslash.chevron.right"
            case .link: return "link"
            case .list: return "list.bullet"
            }
        }

        var label: LocalizedStringKey {
            switch self {
            case .bold: return "Bold"
            case .italic: return "Italic"
            case .heading: return "Heading"
            case .quote: return "Quote"
            case .code: return "Code"
            case .link: return "Link"
            case .list: return "List"
            }
        }

        /// `selected` with the shortcut applied: wrapped for inline styles, prefixed for a line's.
        func applied(to selected: String) -> String {
            switch self {
            case .bold: return "**\(selected)**"
            case .italic: return "*\(selected)*"
            case .code: return selected.contains("\n") ? "```\n\(selected)\n```" : "`\(selected)`"
            case .link: return "[\(selected)](https://)"
            case .heading: return "# " + selected
            case .quote: return "> " + selected
            case .list: return "- " + selected
            }
        }

        /// `text` with the shortcut's empty form added at its end; a line's style starts a new line.
        func appending(to text: String) -> String {
            let lineStyle = self == .heading || self == .quote || self == .list
            let separator = lineStyle && !text.isEmpty && !text.hasSuffix("\n") ? "\n" : ""
            return text + separator + applied(to: "")
        }
    }

    /// The editor where the system shares the selection: a shortcut wraps what is selected, or adds to the end.
    @available(iOS 18.0, macOS 15.0, *)
    private struct SelectingEditor: View {
        @Binding var text: String
        @Binding var shortcut: MarkdownShortcut?
        @State private var selection: TextSelection?

        var body: some View {
            TextEditor(text: $text, selection: $selection)
                .onChange(of: shortcut) {
                    guard let shortcut else { return }
                    apply(shortcut)
                    self.shortcut = nil
                }
        }

        private func apply(_ shortcut: MarkdownShortcut) {
            if case .selection(let range)? = selection?.indices, !range.isEmpty,
               range.lowerBound >= text.startIndex, range.upperBound <= text.endIndex {
                text.replaceSubrange(range, with: shortcut.applied(to: String(text[range])))
                selection = nil
            } else {
                text = shortcut.appending(to: text)
            }
        }
    }

    //@endif

    private struct MarkdownEditorPreview: View {
        @State private var text = "Roast the tomatoes **slowly**."

        var body: some View {
            MarkdownEditorView(text: $text)
                .frame(height: 300)
        }
    }

    #Preview {
        MarkdownEditorPreview()
    }
    """##
}
