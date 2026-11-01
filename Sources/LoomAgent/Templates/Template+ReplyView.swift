//  WHAT: The template of `ReplyView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let replyView = ##"""
    import SwiftUI

    /// A reply, as Loom writes one: who and what it answers at the top (scrollable when long), the text in Markdown
    /// with its shortcuts, and a send button below. An error is shown and the reply kept; a sheet that holds it closes
    /// when the reply is sent.
    struct ReplyView<Social: SocialSchema>: View {
        /// The post or the comment it answers.
        var target: SocialTarget<Social>
        /// The reply being edited: its text starts the draft.
        var editing: Social.Comment? = nil
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        @Environment(\.dismiss) private var dismiss
        @State private var text = ""
        @State private var posting = false
        @State private var failure: String?
        @State private var started = false

        var body: some View {
            let palette = style.palette
            let info = target.content
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: SocialSpacing.layer2) {
                    AvatarView(url: info?.authorAvatar, size: .small)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: info?.authorName ?? "")
                            .font(.headline)
                            .lineLimit(1)
                        if let handle = info?.authorHandle {
                            Text(verbatim: "@" + handle)
                                .font(.caption2)
                                .foregroundStyle(palette.foreground.opacity(0.5))
                        }
                    }
                    Spacer(minLength: 0)
                    if let created = info?.created {
                        Text(verbatim: SocialFormat.relative(created))
                            .font(.footnote)
                            .foregroundStyle(palette.foreground.opacity(0.5))
                    }
                }
                .foregroundStyle(palette.foreground)
                .padding(.horizontal, SocialSpacing.layer4)
                .padding(.bottom, SocialSpacing.layer4)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                        switch target {
                        case .post(let post):
                            if !post.socialTitle.isEmpty {
                                Text(verbatim: post.socialTitle).font(.headline).foregroundStyle(palette.foreground)
                            }
                            if let body = post.socialBody, !body.isEmpty { MarkdownBodyView(text: body) }
                        case .comment(let comment):
                            MarkdownBodyView(text: comment.socialText)
                        case .user, .community, .instance:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SocialSpacing.layer4)
                }
                .frame(maxHeight: 160)
                .fixedSize(horizontal: false, vertical: true)

                Divider()

                if let failure {
                    Text(verbatim: failure)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, SocialSpacing.layer4)
                        .padding(.vertical, SocialSpacing.layer2)
                }
                MarkdownEditorView(text: $text, placeholder: "Write a reply...")

                Divider()

                HStack {
                    Spacer()
                    if posting {
                        ProgressView().controlSize(.small)
                    } else {
                        Button { Task { await send() } } label: {
                            Image(systemName: editing == nil ? "paperplane.fill" : "checkmark")
                                .font(.headline)
                                .frame(width: 44, height: 24)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || actions.submit == nil)
                        .accessibilityLabel(editing == nil ? Text("Send reply") : Text("Save reply"))
                    }
                    Spacer()
                }
                .foregroundStyle(palette.foreground)
                .frame(height: 24)
                .padding(.vertical, SocialSpacing.layer4)
            }
            .padding(.top, SocialSpacing.layer4)
            .background(palette.background)
            .onAppear {
                guard !started else { return }
                started = true
                if let editing { text = editing.socialText }
            }
        }

        private func send() async {
            guard let submit = actions.submit else { return }
            var draft = SocialDraft<Social>()
            draft.body = text
            draft.replyingTo = target
            draft.editing = editing.map { .comment($0) }
            posting = true
            failure = nil
            do {
                try await submit(draft)
                posting = false
                text = ""
                dismiss()
            } catch {
                posting = false
                failure = error.localizedDescription
            }
        }
    }

    #Preview {
        ReplyView(target: .comment(SocialSample.comments[0]), actions: SocialActions<SocialSample>.sample)
            .frame(height: 500)
    }
    """##
}
