//  WHAT: The template of `ReportView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let reportView = ##"""
    import SwiftUI

    /// A report, as Loom takes one: what is reported in the title, the reason in a text box, and a submit button. A
    /// sent report says so; an error is shown and the reason kept.
    struct ReportView<Social: SocialSchema>: View {
        var target: SocialTarget<Social>
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        @Environment(\.dismiss) private var dismiss
        @State private var reason = ""
        @State private var sending = false
        @State private var sent = false
        @State private var failure: String?

        var body: some View {
            let palette = style.palette
            VStack(alignment: .leading, spacing: SocialSpacing.layer4) {
                title
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                Divider()
                TextEditor(text: $reason)
                    .font(.title3)
                    .scrollContentBackground(.hidden)
                    .frame(height: 160)
                    .padding(SocialSpacing.layer3)
                    .background(palette.tertiaryBackground, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .topLeading) {
                        if reason.isEmpty {
                            Text("Why should moderators look at this?")
                                .font(.title3)
                                .foregroundStyle(palette.foreground.opacity(0.3))
                                .padding(SocialSpacing.layer3 + 6)
                                .allowsHitTesting(false)
                        }
                    }
                if let failure {
                    Text(verbatim: failure).font(.footnote).foregroundStyle(.red)
                }
                HStack {
                    Spacer()
                    if sent {
                        Label("Reported", systemImage: "checkmark.circle.fill").font(.headline)
                    } else if sending {
                        ProgressView().controlSize(.small)
                    } else {
                        Button("Submit") { Task { await send() } }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .disabled(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || actions.sendReport == nil)
                    }
                    Spacer()
                }
            }
            .foregroundStyle(palette.foreground)
            .padding(SocialSpacing.layer5)
            .background(palette.background)
        }

        private var title: Text {
            switch target {
            case .post: return Text("Report post")
            case .comment: return Text("Report comment")
            case .user: return Text("Report person")
            case .community: return Text("Report community")
            case .instance: return Text("Report server")
            }
        }

        private func send() async {
            guard let sendReport = actions.sendReport else { return }
            sending = true
            failure = nil
            do {
                try await sendReport(target, reason.trimmingCharacters(in: .whitespacesAndNewlines))
                sending = false
                sent = true
                try? await Task.sleep(nanoseconds: 800_000_000)
                dismiss()
            } catch {
                sending = false
                failure = error.localizedDescription
            }
        }
    }

    #Preview {
        ReportView(target: .post(SocialSample.posts[0]), actions: .sample)
    }
    """##
}
