//  WHAT: The template of `MarkdownBodyView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let markdownBodyView = ##"""
    import SwiftUI

    /// Text written in Markdown, shown with its headings, quotes, lists and code blocks, and its inline emphasis and
    /// links. Plain SwiftUI: the blocks are read here, the inline styles by `AttributedString`.
    struct MarkdownBodyView: View {
        var text: String
        var font: Font = .subheadline
        /// The most lines a preview shows; nil shows everything.
        var lineLimit: Int? = nil

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
    //@if markdown
            VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                ForEach(Array(Self.blocks(text).enumerated()), id: \.offset) { _, block in
                    view(block, palette)
                }
            }
            .lineLimit(lineLimit)
            .frame(maxWidth: .infinity, alignment: .leading)
    //@else
            Text(text)
                .font(font)
                .foregroundStyle(palette.foreground.opacity(0.9))
                .lineLimit(lineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)
    //@endif
        }
    //@if markdown

        enum Block: Equatable {
            case paragraph(String)
            case heading(Int, String)
            case quote(String)
            case bullet(String)
            case numbered(String, String)
            case code(String)
            case rule
        }

        @ViewBuilder
        private func view(_ block: Block, _ palette: SocialPalette) -> some View {
            switch block {
            case .paragraph(let text):
                Text(Self.inline(text))
                    .font(font)
                    .foregroundStyle(palette.foreground.opacity(0.9))
            case .heading(let level, let text):
                Text(Self.inline(text))
                    .font(level == 1 ? .title.bold() : level == 2 ? .title2.bold() : level == 3 ? .title3.bold() : .headline)
                    .foregroundStyle(palette.foreground)
            case .quote(let text):
                HStack(alignment: .top, spacing: SocialSpacing.layer2) {
                    RoundedRectangle(cornerRadius: 1).fill(palette.secondaryForeground).frame(width: 3)
                    Text(Self.inline(text))
                        .font(font)
                        .foregroundStyle(palette.secondaryForeground)
                }
                .fixedSize(horizontal: false, vertical: true)
            case .bullet(let text):
                HStack(alignment: .firstTextBaseline, spacing: SocialSpacing.layer2) {
                    Text(verbatim: "•").font(font)
                    Text(Self.inline(text)).font(font)
                }
                .foregroundStyle(palette.foreground.opacity(0.9))
            case .numbered(let number, let text):
                HStack(alignment: .firstTextBaseline, spacing: SocialSpacing.layer2) {
                    Text(verbatim: number + ".").font(font.monospacedDigit())
                    Text(Self.inline(text)).font(font)
                }
                .foregroundStyle(palette.foreground.opacity(0.9))
            case .code(let text):
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(verbatim: text)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(palette.foreground)
                        .padding(SocialSpacing.layer2)
                }
                .background(palette.tertiaryBackground.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
            case .rule:
                Divider()
            }
        }

        /// Inline Markdown (emphasis, code, links) as styled text; the text as it is when it is not Markdown.
        static func inline(_ text: String) -> AttributedString {
            let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
        }

        /// The blocks of `text`: paragraphs joined across single line breaks, the rest one line each.
        static func blocks(_ text: String) -> [Block] {
            var blocks: [Block] = []
            var paragraph: [String] = []
            var code: [String]?
            func flush() {
                if !paragraph.isEmpty { blocks.append(.paragraph(paragraph.joined(separator: " "))) }
                paragraph = []
            }
            for raw in text.components(separatedBy: .newlines) {
                let line = raw.trimmingCharacters(in: .whitespaces)
                if line.hasPrefix("```") {
                    if let lines = code {
                        blocks.append(.code(lines.joined(separator: "\n")))
                        code = nil
                    } else {
                        flush()
                        code = []
                    }
                    continue
                }
                if code != nil {
                    code?.append(raw)
                    continue
                }
                if line.isEmpty {
                    flush()
                } else if let hashes = line.firstIndex(where: { $0 != "#" }), line.hasPrefix("#"), line[hashes] == " " {
                    flush()
                    let level = line.distance(from: line.startIndex, to: hashes)
                    blocks.append(.heading(min(level, 4), String(line[hashes...]).trimmingCharacters(in: .whitespaces)))
                } else if line.hasPrefix(">") {
                    flush()
                    blocks.append(.quote(String(line.dropFirst()).trimmingCharacters(in: .whitespaces)))
                } else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                    flush()
                    blocks.append(.bullet(String(line.dropFirst(2))))
                } else if let dot = line.firstIndex(of: "."), line[..<dot].allSatisfy(\.isNumber), !line[..<dot].isEmpty,
                          line[line.index(after: dot)...].hasPrefix(" ") {
                    flush()
                    blocks.append(.numbered(String(line[..<dot]), String(line[line.index(after: dot)...]).trimmingCharacters(in: .whitespaces)))
                } else if line == "---" || line == "***" {
                    flush()
                    blocks.append(.rule)
                } else {
                    paragraph.append(line)
                }
            }
            if let lines = code { blocks.append(.code(lines.joined(separator: "\n"))) }
            flush()
            return blocks
        }
    //@endif
    }

    #Preview {
        MarkdownBodyView(text: """
        # Tomato soup
        Roast the tomatoes **slowly**, then blend with *basil oil*.

        > Better the next day.

        - 1 kg tomatoes
        - 1 head of garlic
        """)
        .padding()
    }
    """##
}
