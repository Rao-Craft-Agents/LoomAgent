//  WHAT: The template of `UserProfileHeaderView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let userProfileHeaderView = ##"""
    import SwiftUI

    /// The top of a profile: the banner when there is one, the picture beside where they are from and their name in
    /// large type, what they say about themselves, and their numbers (scores, posts, comments, followers) with when
    /// they joined.
    struct UserProfileHeaderView<Social: SocialSchema>: View {
        var user: Social.User
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            let hasBanner = user.socialBanner != nil
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: SocialSpacing.layer3) {
                    AvatarView(url: user.socialAvatar, size: hasBanner ? .large : .medium,
                               ring: user.socialIsAdmin ? palette.admin : .clear)
                    VStack(alignment: .leading, spacing: 0) {
                        if let handle = user.socialHandle {
                            Text(verbatim: handle)
                                .font(.footnote)
                                .modifier(Readable(isOn: hasBanner, palette: palette))
                        }
                        Text(verbatim: user.socialDisplayName ?? user.socialName)
                            .font(.title.bold())
                            .lineLimit(2)
                            .modifier(Readable(isOn: hasBanner, palette: palette))
                            .padding(.top, hasBanner ? SocialSpacing.layer1 : 0)
                            .accessibilityAddTraits(.isHeader)
                    }
                    Spacer(minLength: 0)
                    if user.socialIsBot {
                        Text(verbatim: "🤖").font(.title3).accessibilityLabel(Text("Bot"))
                    }
                }
                .padding(.horizontal, SocialSpacing.layer4)
                .padding(.top, hasBanner ? SocialSpacing.layer6 : SocialSpacing.layer3)
                .padding(.bottom, SocialSpacing.layer3)
                .background(alignment: .top) {
                    if hasBanner { BannerView(url: user.socialBanner, height: 160) }
                }
                .clipped()

                VStack(alignment: .leading, spacing: SocialSpacing.layer3) {
                    if let bio = user.socialBio, !bio.isEmpty {
                        MarkdownBodyView(text: bio)
                            .padding(SocialSpacing.layer3)
                            .background(palette.secondaryBackground.opacity(0.75), in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.foreground.opacity(0.3), lineWidth: 1))
                    }
                    numbers(palette)
                }
                .padding(.horizontal, SocialSpacing.layer4)
                .padding(.bottom, SocialSpacing.layer3)
            }
            .foregroundStyle(palette.foreground)
        }

        @ViewBuilder
        private func numbers(_ palette: SocialPalette) -> some View {
            VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                if user.socialPostScore != nil || user.socialCommentScore != nil {
                    HStack(spacing: SocialSpacing.layer2) {
                        if let score = user.socialPostScore {
                            Text("\(SocialFormat.count(score)) post score")
                        }
                        if user.socialPostScore != nil, user.socialCommentScore != nil {
                            Text(verbatim: "·")
                        }
                        if let score = user.socialCommentScore {
                            Text("\(SocialFormat.count(score)) comment score")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(palette.secondaryForeground)
                }
                HStack(spacing: SocialSpacing.layer2) {
                    if let posts = user.socialPostCount {
                        chip(Text("\(SocialFormat.count(posts)) posts"), palette.stat)
                    }
                    if let comments = user.socialCommentCount {
                        chip(Text("\(SocialFormat.count(comments)) comments"), palette.stat)
                    }
                    if let followers = user.socialFollowerCount {
                        chip(Text("\(SocialFormat.count(followers)) followers"), palette.tertiaryBackground)
                    }
                    if let following = user.socialFollowingCount {
                        chip(Text("\(SocialFormat.count(following)) following"), palette.tertiaryBackground)
                    }
                }
                if let joined = user.socialJoined {
                    Label {
                        Text("Joined \(joined.formatted(.dateTime.month(.wide).year()))")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(palette.secondaryForeground)
                }
            }
        }

        private func chip(_ text: Text, _ color: Color) -> some View {
            text
                .font(.caption.bold())
                .padding(.vertical, SocialSpacing.layer1)
                .padding(.horizontal, SocialSpacing.layer2)
                .background(color, in: RoundedRectangle(cornerRadius: 4))
        }
    }

    /// Loom's readability: text over a banner sits on a soft plate of the background.
    private struct Readable: ViewModifier {
        var isOn: Bool
        var palette: SocialPalette

        func body(content: Content) -> some View {
            if isOn {
                content
                    .padding(.horizontal, SocialSpacing.layer2)
                    .padding(.vertical, SocialSpacing.layer1)
                    .background(palette.background.opacity(0.75), in: RoundedRectangle(cornerRadius: 6))
            } else {
                content
            }
        }
    }

    #Preview {
        UserProfileHeaderView(user: SocialSample.users[0], actions: .sample)
    }
    """##
}
