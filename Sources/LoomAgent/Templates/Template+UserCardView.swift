//  WHAT: The template of `UserCardView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let userCardView = ##"""
    import SwiftUI

    /// A person as a list shows them, as Loom draws it: their picture, the name they show over their username and
    /// where they are from in a small chip, and their menu; with counts, their score and a chip each for their posts
    /// and comments. The compact card stacks the picture over the name, for a row that scrolls sideways.
    struct UserCardView<Social: SocialSchema>: View {
        var user: Social.User
        var actions: SocialActions<Social>
        var isCompact = false
        var showsCounts = false

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            Group {
                if isCompact {
                    VStack(spacing: SocialSpacing.layer1) {
                        AvatarView(url: user.socialAvatar, size: .large)
                            .padding(.bottom, SocialSpacing.layer1)
                        Text(verbatim: user.socialDisplayName ?? user.socialName)
                            .font(.footnote.bold())
                            .lineLimit(1)
                        if let handle = user.socialHandle {
                            chip("@" + handle, palette)
                        }
                    }
                    .padding(.vertical, SocialSpacing.layer3)
                    .padding(.horizontal, SocialSpacing.layer2)
                    .frame(minWidth: 100)
                    .background(palette.secondaryBackground, in: RoundedRectangle(cornerRadius: 8))
                } else {
                    VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                        HStack(spacing: SocialSpacing.layer3) {
                            AvatarView(url: user.socialAvatar, size: showsCounts ? .large : .small,
                                       ring: user.socialIsAdmin ? palette.admin : .clear)
                            VStack(alignment: .leading, spacing: 0) {
                                if showsCounts, let score = user.socialScore {
                                    Text("Score: \(SocialFormat.count(score))").font(.headline)
                                }
                                if let display = user.socialDisplayName {
                                    Text(verbatim: display)
                                        .font(showsCounts ? .headline.bold() : .footnote.bold())
                                        .lineLimit(1)
                                }
                                HStack(spacing: SocialSpacing.layer2) {
                                    Text(verbatim: "@" + user.socialName)
                                        .font(showsCounts ? .headline : .subheadline)
                                        .lineLimit(1)
                                    if let handle = user.socialHandle {
                                        chip("@" + handle, palette)
                                    }
                                }
                            }
                            Spacer(minLength: 0)
                            menu(palette)
                        }
                        if showsCounts { counts(palette) }
                    }
                    .padding(SocialSpacing.layer3)
                    .background(palette.secondaryBackground, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .foregroundStyle(palette.foreground)
            .contentShape(Rectangle())
            .onTapGesture { actions.openUser?(.user(user)) }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(actions.openUser == nil ? [] : .isButton)
        }

        private func chip(_ text: String, _ palette: SocialPalette) -> some View {
            Text(verbatim: text)
                .font(.caption)
                .lineLimit(1)
                .padding(.horizontal, SocialSpacing.layer1)
                .padding(.vertical, 2)
                .background(palette.tertiaryBackground, in: RoundedRectangle(cornerRadius: 4))
        }

        @ViewBuilder
        private func counts(_ palette: SocialPalette) -> some View {
            HStack(spacing: SocialSpacing.layer2) {
                if let posts = user.socialPostCount {
                    stat(Text("\(SocialFormat.count(posts)) posts"), palette)
                }
                if let comments = user.socialCommentCount {
                    stat(Text("\(SocialFormat.count(comments)) comments"), palette)
                }
                if let followers = user.socialFollowerCount {
                    stat(Text("\(SocialFormat.count(followers)) followers"), palette)
                }
            }
        }

        private func stat(_ text: Text, _ palette: SocialPalette) -> some View {
            text
                .font(.caption.bold())
                .padding(.vertical, SocialSpacing.layer1)
                .padding(.horizontal, SocialSpacing.layer2)
                .background(palette.stat, in: RoundedRectangle(cornerRadius: 4))
        }

        @ViewBuilder
        private func menu(_ palette: SocialPalette) -> some View {
            let target = SocialTarget<Social>.user(user)
            Menu {
                if let openUser = actions.openUser {
                    Button { openUser(target) } label: { Label("View profile", systemImage: "person") }
                }
    //@if share
                if let share = actions.share {
                    Button { share(target) } label: { Label("Share", systemImage: "paperplane") }
                }
    //@endif
                if !user.socialIsMine {
    //@if block
                    if let block = actions.block {
                        if user.socialIsBlocked {
                            Button { block(target) } label: { Label("Unblock \(user.socialName)", systemImage: "hand.raised.slash") }
                        } else {
                            Button(role: .destructive) { block(target) } label: { Label("Block \(user.socialName)", systemImage: "hand.raised") }
                        }
                    }
    //@endif
    //@if report
                    if let report = actions.report {
                        Button(role: .destructive) { report(target) } label: { Label("Report \(user.socialName)", systemImage: "flag") }
                    }
    //@endif
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.footnote.bold())
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

    #Preview {
        VStack(spacing: SocialSpacing.layer4) {
            UserCardView(user: SocialSample.users[0], actions: .sample, showsCounts: true)
            UserCardView(user: SocialSample.users[1], actions: .sample)
            HStack {
                ForEach(SocialSample.users) { user in
                    UserCardView(user: user, actions: .sample, isCompact: true)
                }
            }
        }
        .padding()
    }
    """##
}
