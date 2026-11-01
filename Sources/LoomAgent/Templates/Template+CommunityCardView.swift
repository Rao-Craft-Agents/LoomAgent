//  WHAT: The template of `CommunityCardView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let communityCardView = ##"""
    import SwiftUI

    /// A community, in Loom's two shapes. The card: its picture, how many subscribe, its title, its name with where
    /// it lives in a small chip, and with counts a row of chips for who was active and what it holds. The capsule: a
    /// small picture, the name and the place on one rounded line, for a list or a picker.
    struct CommunityCardView<Social: SocialSchema>: View {
        var community: Social.Community
        var actions: SocialActions<Social>
        var isCompact = false
        var showsCounts = true

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            Group {
                if isCompact {
                    HStack(spacing: SocialSpacing.layer3) {
                        AvatarView(url: community.socialIcon, size: .mini, kind: .community)
                        HStack(spacing: SocialSpacing.layer1) {
                            Text(verbatim: community.socialName)
                                .font(.subheadline)
                                .lineLimit(1)
                            if let handle = community.socialHandle {
                                chip("@" + handle, palette)
                            }
                        }
                        Spacer(minLength: 0)
                        menu(palette)
                    }
                    .padding(SocialSpacing.layer3)
                    .background(palette.secondaryBackground, in: Capsule())
                } else {
                    VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                        HStack(spacing: SocialSpacing.layer3) {
                            AvatarView(url: community.socialIcon, size: .large, kind: .community)
                            VStack(alignment: .leading, spacing: 0) {
                                if let subscribers = community.socialSubscriberCount {
                                    Text("\(SocialFormat.count(subscribers)) subscribers")
                                        .font(.headline.bold())
                                }
                                Text(verbatim: community.socialTitle ?? community.socialName)
                                    .font(showsCounts ? .headline.bold() : .footnote.bold())
                                    .lineLimit(1)
                                HStack(spacing: SocialSpacing.layer1) {
                                    Text(verbatim: community.socialName)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    if let handle = community.socialHandle {
                                        chip("@" + handle, palette)
                                    }
                                }
                            }
                            Spacer(minLength: 0)
                            menu(palette)
                        }
                        .padding(SocialSpacing.layer3)
                        .background(palette.secondaryBackground, in: RoundedRectangle(cornerRadius: 8))
                        if showsCounts { counts(palette) }
                    }
                }
            }
            .foregroundStyle(palette.foreground)
            .contentShape(Rectangle())
            .onTapGesture { actions.openCommunity?(.community(community)) }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(actions.openCommunity == nil ? [] : .isButton)
        }

        private func chip(_ text: String, _ palette: SocialPalette) -> some View {
            Text(verbatim: text)
                .font(.caption2)
                .lineLimit(1)
                .padding(.horizontal, SocialSpacing.layer1)
                .padding(.vertical, 2)
                .background(palette.tertiaryBackground, in: RoundedRectangle(cornerRadius: 4))
        }

        /// Loom's two groups of chips: who was active, and what it holds.
        @ViewBuilder
        private func counts(_ palette: SocialPalette) -> some View {
            let active = [community.socialActiveToday, community.socialActiveThisWeek, community.socialActiveThisMonth]
            let holds = community.socialPostCount != nil || community.socialCommentCount != nil
            if active.contains(where: { $0 != nil }) || holds {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: SocialSpacing.layer4) {
                        if active.contains(where: { $0 != nil }) {
                            VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                                Text("Users").font(.headline.bold())
                                HStack(spacing: SocialSpacing.layer2) {
                                    if let today = community.socialActiveToday {
                                        stat(Text("\(SocialFormat.count(today)) / day"), palette.tertiaryBackground.opacity(0.9))
                                    }
                                    if let week = community.socialActiveThisWeek {
                                        stat(Text("\(SocialFormat.count(week)) / week"), palette.tertiaryBackground.opacity(0.9))
                                    }
                                    if let month = community.socialActiveThisMonth {
                                        stat(Text("\(SocialFormat.count(month)) / month"), palette.tertiaryBackground.opacity(0.9))
                                    }
                                }
                            }
                        }
                        if holds {
                            VStack(alignment: .leading, spacing: SocialSpacing.layer2) {
                                Text("Stats").font(.headline.bold())
                                HStack(spacing: SocialSpacing.layer2) {
                                    if let posts = community.socialPostCount {
                                        stat(Text("\(SocialFormat.count(posts)) posts"), palette.stat)
                                    }
                                    if let comments = community.socialCommentCount {
                                        stat(Text("\(SocialFormat.count(comments)) comments"), palette.stat)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        private func stat(_ text: Text, _ color: Color) -> some View {
            text
                .font(.caption)
                .padding(.vertical, SocialSpacing.layer1)
                .padding(.horizontal, SocialSpacing.layer2)
                .background(color, in: RoundedRectangle(cornerRadius: 4))
        }

        @ViewBuilder
        private func menu(_ palette: SocialPalette) -> some View {
            let target = SocialTarget<Social>.community(community)
            Menu {
                if let openCommunity = actions.openCommunity {
                    Button { openCommunity(target) } label: { Label("Go to \(community.socialName)", systemImage: "arrow.right.circle") }
                }
                if let subscribe = actions.subscribe {
                    if community.socialIsSubscribed {
                        Button { subscribe(community) } label: { Label("Unsubscribe", systemImage: "minus.circle") }
                    } else {
                        Button { subscribe(community) } label: { Label("Subscribe", systemImage: "plus.circle") }
                    }
                }
    //@if share
                if let share = actions.share {
                    Button { share(target) } label: { Label("Share", systemImage: "paperplane") }
                }
    //@endif
    //@if block
                if let block = actions.block {
                    if community.socialIsBlocked {
                        Button { block(target) } label: { Label("Unblock \(community.socialName)", systemImage: "hand.raised.slash") }
                    } else {
                        Button(role: .destructive) { block(target) } label: { Label("Block \(community.socialName)", systemImage: "hand.raised") }
                    }
                }
    //@endif
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
            CommunityCardView(community: SocialSample.communities[0], actions: .sample)
            CommunityCardView(community: SocialSample.communities[1], actions: .sample, isCompact: true)
        }
        .padding()
    }
    """##
}
