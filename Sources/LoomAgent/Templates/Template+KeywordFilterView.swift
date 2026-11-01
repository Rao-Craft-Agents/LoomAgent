//  WHAT: The template of `KeywordFilterView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let keywordFilterView = ##"""
    import SwiftUI

    /// The keyword filters, as Loom's settings edit them: a row of chips, one a keyword, with a plus to add one; a tap
    /// on a chip opens it below, to change the word or where it is looked for, or to remove it. The app keeps the
    /// list and hides what it matches with `filters.keeping(posts)`.
    struct KeywordFilterView: View {
        @Binding var filters: [SocialKeywordFilter]

        @Environment(\.socialStyle) private var style
        @State private var editing: SocialKeywordFilter?
        @State private var isNew = false

        var body: some View {
            let palette = style.palette
            VStack(alignment: .leading, spacing: SocialSpacing.layer4) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SocialSpacing.layer3) {
                        Button {
                            editing = SocialKeywordFilter(keyword: "")
                            isNew = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.footnote.bold())
                                .frame(width: 32, height: 32)
                                .background(palette.alternateBackground.opacity(0.7), in: RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.foreground.opacity(0.3), lineWidth: 1))
                        }
                        .accessibilityLabel(Text("Add a keyword"))
                        ForEach(filters) { filter in
                            Button {
                                editing = filter
                                isNew = false
                            } label: {
                                HStack(spacing: SocialSpacing.layer1) {
                                    Text(verbatim: filter.keyword).font(.headline)
                                    Image(systemName: "pencil").font(.subheadline)
                                }
                                .padding(.horizontal, SocialSpacing.layer2)
                                .frame(height: 32)
                                .background(palette.alternateBackground.opacity(0.7), in: RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.foreground.opacity(0.3), lineWidth: 1))
                            }
                            .accessibilityLabel(Text("Edit \(filter.keyword)"))
                        }
                    }
                    .padding(1)
                }
                .buttonStyle(.plain)
                if let filter = editing {
                    editor(filter, palette)
                }
            }
            .foregroundStyle(palette.foreground)
        }

        private func editor(_ filter: SocialKeywordFilter, _ palette: SocialPalette) -> some View {
            let keyword = Binding(get: { editing?.keyword ?? "" }, set: { editing?.keyword = $0 })
            return VStack(alignment: .leading, spacing: SocialSpacing.layer3) {
                HStack {
                    Group {
                        if isNew { Text("Add a keyword") } else { Text("Edit keyword") }
                    }
                    .font(.title3.bold())
                    Spacer()
                    if !isNew {
                        Button(role: .destructive) {
                            filters.removeAll { $0.id == filter.id }
                            editing = nil
                        } label: {
                            Image(systemName: "trash").foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Remove keyword"))
                    }
                }
                TextField("Keyword", text: keyword)
                    .textFieldStyle(.plain)
                    .font(.title3.bold())
                    .autocorrectionDisabled()
                    .padding(SocialSpacing.layer3)
                    .background(palette.tertiaryBackground, in: RoundedRectangle(cornerRadius: 8))
                ForEach(SocialKeywordFilter.Field.allCases, id: \.self) { field in
                    Toggle(isOn: Binding(
                        get: { editing?.fields.contains(field) ?? false },
                        set: { isOn in
                            if isOn { editing?.fields.insert(field) } else { editing?.fields.remove(field) }
                        })) {
                        Self.title(field).font(.headline)
                    }
                }
                HStack {
                    Button("Cancel") { editing = nil }
                    Spacer()
                    Button { save() } label: {
                        if isNew { Text("Add") } else { Text("Save") }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled((editing?.keyword ?? "").trimmingCharacters(in: .whitespaces).isEmpty || editing?.fields.isEmpty == true)
                }
            }
            .padding(SocialSpacing.layer4)
            .background(palette.secondaryBackground, in: RoundedRectangle(cornerRadius: 12))
        }

        private func save() {
            guard var filter = editing else { return }
            filter.keyword = filter.keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            if let index = filters.firstIndex(where: { $0.id == filter.id }) {
                filters[index] = filter
            } else {
                filters.append(filter)
            }
            editing = nil
        }

        private static func title(_ field: SocialKeywordFilter.Field) -> Text {
            switch field {
            case .title: return Text("Post titles")
            case .body: return Text("Post and comment text")
            case .link: return Text("Post links")
            case .community: return Text("Community names")
            case .author: return Text("Authors")
            }
        }
    }

    private struct KeywordFilterPreview: View {
        @State private var filters = [SocialKeywordFilter(keyword: "spoilers"), SocialKeywordFilter(keyword: "cilantro", fields: [.title, .body])]

        var body: some View {
            KeywordFilterView(filters: $filters)
                .padding()
        }
    }

    #Preview {
        KeywordFilterPreview()
    }
    """##
}
