//  WHAT: The template of `ComposeView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let composeView = ##"""
    import PhotosUI
    import SwiftUI

    /// A new post, as Loom writes one: a link and a picture to attach and the community it goes to along the top, then
    /// a title and the text in Markdown with its shortcuts. Posting shows a spinner; an error is shown and the draft
    /// kept, and a sheet that holds it closes when the post is made.
    struct ComposeView<Social: SocialSchema>: View {
        /// The communities the post may go to; the choice is left out when there are none.
        var communities: [Social.Community] = []
        /// The community it starts in.
        var community: Social.Community? = nil
        /// The post being edited: its title, text and link start the draft.
        var editing: Social.Post? = nil
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style
        @Environment(\.dismiss) private var dismiss
        @State private var title = ""
        @State private var text = ""
        @State private var link = ""
        @State private var showsLink = false
        @State private var chosen: Social.Community.ID?
        @State private var photo: PhotosPickerItem?
        @State private var image: Data?
        @State private var posting = false
        @State private var failure: String?
        @State private var started = false

        var body: some View {
            let palette = style.palette
            let attached = image != nil
            VStack(spacing: 0) {
                HStack(spacing: SocialSpacing.layer3) {
                    Button { withAnimation { showsLink.toggle() } } label: {
                        Image(systemName: link.isEmpty ? "link.badge.plus" : "link")
                            .font(.title3)
                            .foregroundStyle(linkColor(palette))
                    }
                    .accessibilityLabel(Text("Link"))
                    PhotosPicker(selection: $photo, matching: .images) {
                        Image(systemName: attached ? "photo" : "photo.badge.plus")
                            .font(.title3)
                            .foregroundStyle(attached ? Color.green.opacity(0.8) : palette.foreground)
                    }
                    .accessibilityLabel(Text("Attach a picture"))
                    if attached {
                        Button { photo = nil; image = nil } label: {
                            Image(systemName: "trash").font(.title3).foregroundStyle(.red.opacity(0.8))
                        }
                        .accessibilityLabel(Text("Remove the picture"))
                    }
                    Spacer(minLength: 0)
                    if posting {
                        ProgressView().controlSize(.small)
                    } else {
                        if !communities.isEmpty, editing == nil {
                            communityMenu(palette)
                        }
                        Button { Task { await post() } } label: {
                            Image(systemName: editing == nil ? "paperplane.fill" : "checkmark")
                                .font(.headline)
                                .contentShape(Rectangle())
                        }
                        .disabled(!canPost)
                        .accessibilityLabel(editing == nil ? Text("Post") : Text("Save"))
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(palette.foreground)
                .frame(height: 24)
                .padding(.horizontal, SocialSpacing.layer4)
                .padding(.bottom, SocialSpacing.layer4)

                Divider()

                if showsLink {
                    TextField("Link", text: $link)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        #endif
                        .padding(.horizontal, SocialSpacing.layer4)
                        .frame(height: 44)
                    Divider()
                }
                if let image, let picture = Self.picture(image) {
                    picture
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(SocialSpacing.layer3)
                        .accessibilityLabel(Text("The attached picture"))
                    Divider()
                }
                if let failure {
                    Text(verbatim: failure)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, SocialSpacing.layer4)
                        .padding(.vertical, SocialSpacing.layer2)
                }
                TextField("Title", text: $title)
                    .textFieldStyle(.plain)
                    .font(.title3.bold())
                    .frame(height: 30)
                    .padding(.horizontal, SocialSpacing.layer4)
                    .padding(.top, SocialSpacing.layer2)
                Divider()
                    .padding(.top, SocialSpacing.layer2)
                MarkdownEditorView(text: $text)
            }
            .padding(.top, SocialSpacing.layer4)
            .background(palette.background)
            .task(id: photo) {
                guard let photo else { return }
                image = try? await photo.loadTransferable(type: Data.self)
            }
            .onAppear {
                guard !started else { return }
                started = true
                chosen = community?.id
                if let editing {
                    title = editing.socialTitle
                    text = editing.socialBody ?? ""
                    link = editing.socialURL?.absoluteString ?? ""
                    showsLink = !link.isEmpty
                }
            }
        }

        private func communityMenu(_ palette: SocialPalette) -> some View {
            let current = communities.first { $0.id == chosen }
            return Menu {
                ForEach(communities) { community in
                    Button { chosen = community.id } label: {
                        Text(verbatim: community.socialTitle ?? community.socialName)
                    }
                }
            } label: {
                HStack(spacing: SocialSpacing.layer2) {
                    if let current {
                        Text(verbatim: current.socialName).font(.headline.bold())
                        AvatarView(url: current.socialIcon, size: .mini, kind: .community)
                    } else {
                        Text("Choose a community").font(.headline.bold())
                        Image(systemName: "globe").font(.title3)
                    }
                }
                .foregroundStyle(current == nil ? Color.red : palette.foreground)
                .opacity(0.8)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .fixedSize()
            .accessibilityLabel(Text("Community"))
        }

        /// Loom's link colour: plain while empty, red while it is not a link, green once it is.
        private func linkColor(_ palette: SocialPalette) -> Color {
            if link.isEmpty { return palette.foreground }
            return linkURL == nil ? .red.opacity(0.8) : .green.opacity(0.8)
        }

        private var linkURL: URL? {
            guard let url = URL(string: link.trimmingCharacters(in: .whitespaces)), url.host() != nil else { return nil }
            return url
        }

        private var canPost: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && (link.isEmpty || linkURL != nil)
                && (communities.isEmpty || chosen != nil || editing != nil)
                && actions.submit != nil
        }

        private func post() async {
            guard let submit = actions.submit else { return }
            var draft = SocialDraft<Social>()
            draft.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            draft.body = text
            draft.link = linkURL
            draft.image = image
            draft.community = communities.first { $0.id == chosen } ?? community
            draft.editing = editing.map { .post($0) }
            posting = true
            failure = nil
            do {
                try await submit(draft)
                posting = false
                title = ""; text = ""; link = ""; image = nil; photo = nil
                dismiss()
            } catch {
                posting = false
                failure = error.localizedDescription
            }
        }

        private static func picture(_ data: Data) -> Image? {
            #if os(iOS)
            return UIImage(data: data).map { Image(uiImage: $0) }
            #else
            return NSImage(data: data).map { Image(nsImage: $0) }
            #endif
        }
    }

    #Preview {
        ComposeView(communities: SocialSample.communities, actions: SocialActions<SocialSample>.sample)
            .frame(height: 500)
    }
    """##
}
