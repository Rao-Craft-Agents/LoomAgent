//  WHAT: The template of `ContentMenuView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let contentMenuView = ##"""
    import SwiftUI

    /// The `…` menu of a post or a comment: where to go from it, what to do with it, and, for the person's own
    /// content, edit and delete in place of block and report. Hidden when it would offer nothing.
    struct ContentMenuView<Social: SocialSchema>: View {
        var target: SocialTarget<Social>
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style

        var body: some View {
            if ContentMenuItems<Social>.offersAnything(target, actions) {
                Menu {
                    ContentMenuItems(target: target, actions: actions)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.footnote.bold())
                        .foregroundStyle(style.palette.foreground)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
                .menuIndicator(.hidden)
                .fixedSize()
                .accessibilityLabel(Text("More"))
            }
        }
    }

    /// The items of a post's or a comment's menu, for its `…` button and, on the Mac, its context menu.
    struct ContentMenuItems<Social: SocialSchema>: View {
        var target: SocialTarget<Social>
        var actions: SocialActions<Social>

        @Environment(\.socialContext) private var context
        @Environment(\.openURL) private var openURL

        var body: some View {
            let info = target.content
            if case .post(let post) = target {
                if let community = post.socialCommunityName, let openCommunity = actions.openCommunity {
                    Button { openCommunity(target) } label: { Label("Go to \(community)", systemImage: "arrow.right.circle") }
                }
                if context != .post, let openPost = actions.openPost {
                    Button { openPost(post) } label: { Label("Go to post", systemImage: "arrow.right.circle") }
                }
            }
            if let openUser = actions.openUser, let name = info?.authorName, !name.isEmpty {
                Button { openUser(target) } label: { Label("View \(name)'s profile", systemImage: "person") }
            }
            Divider()
    //@if save
            if let save = actions.save {
                if info?.isSaved == true {
                    Button { save(target) } label: { Label("Remove bookmark", systemImage: "bookmark.fill") }
                } else {
                    Button { save(target) } label: { Label("Bookmark", systemImage: "bookmark") }
                }
            }
    //@endif
    //@if share
            if let share = actions.share {
                Button { share(target) } label: { Label("Share", systemImage: "paperplane") }
            }
    //@endif
            if let link = info?.permalink {
                Button { Self.copy(link) } label: { Label("Copy link", systemImage: "doc.on.clipboard") }
                Button { openURL(link) } label: { Label("Open in browser", systemImage: "safari") }
            }
            Divider()
    //@if reply
            if context.isInteractive, let reply = actions.reply {
                Button { reply(target) } label: { Label("Reply", systemImage: "arrowshape.turn.up.left") }
            }
    //@endif
            if info?.isMine == true {
    //@if editing
                if let edit = actions.edit {
                    Button { edit(target) } label: { Label("Edit", systemImage: "pencil") }
                }
                if let delete = actions.delete {
                    if info?.isDeleted == true {
                        Button { delete(target) } label: { Label("Restore", systemImage: "arrow.counterclockwise.circle") }
                    } else {
                        Button(role: .destructive) { delete(target) } label: { Label("Delete", systemImage: "trash") }
                    }
                }
    //@endif
            } else {
    //@if block
                if let block = actions.block, let name = info?.authorName, !name.isEmpty {
                    Button(role: .destructive) { block(target) } label: { Label("Block \(name)", systemImage: "hand.raised") }
                }
    //@endif
    //@if report
                if let report = actions.report {
                    Button(role: .destructive) { report(target) } label: { Label("Report", systemImage: "flag") }
                }
    //@endif
            }
        }

        /// Whether the menu would hold an item, so an empty `…` is never drawn.
        static func offersAnything(_ target: SocialTarget<Social>, _ actions: SocialActions<Social>) -> Bool {
            let info = target.content
            var offers = info?.permalink != nil || actions.openUser != nil
            if case .post(let post) = target {
                offers = offers || actions.openPost != nil || (post.socialCommunityName != nil && actions.openCommunity != nil)
            }
    //@if save
            offers = offers || actions.save != nil
    //@endif
    //@if share
            offers = offers || actions.share != nil
    //@endif
    //@if reply
            offers = offers || actions.reply != nil
    //@endif
    //@if editing
            offers = offers || (info?.isMine == true && (actions.edit != nil || actions.delete != nil))
    //@endif
    //@if block
            offers = offers || (info?.isMine != true && actions.block != nil)
    //@endif
    //@if report
            offers = offers || (info?.isMine != true && actions.report != nil)
    //@endif
            return offers
        }

        private static func copy(_ link: URL) {
            #if os(iOS)
            UIPasteboard.general.url = link
            #else
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(link.absoluteString, forType: .string)
            #endif
        }
    }

    #Preview {
        ContentMenuView(target: .post(SocialSample.posts[0]), actions: .sample)
            .padding()
    }
    """##
}
