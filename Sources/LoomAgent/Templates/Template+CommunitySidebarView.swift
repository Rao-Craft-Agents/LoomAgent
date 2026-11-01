//  WHAT: The template of `CommunitySidebarView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let communitySidebarView = ##"""
    import SwiftUI

    /// What a community is about, as Loom's sidebar sheet shows it: its banner, its card, a subscribe button, then its
    /// description and rules in Markdown on a soft plate.
    struct CommunitySidebarView<Social: SocialSchema>: View {
        var community: Social.Community
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            ScrollView {
                VStack(alignment: .leading, spacing: SocialSpacing.layer4) {
                    if community.socialBanner != nil {
                        BannerView(url: community.socialBanner, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    CommunityCardView(community: community, actions: actions)
                    if let subscribe = actions.subscribe {
                        Button {
                            subscribe(community)
                        } label: {
                            Group {
                                if community.socialIsSubscribed { Text("Unsubscribe") } else { Text("Subscribe") }
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(community.socialIsSubscribed ? palette.tertiaryBackground : palette.accent)
                    }
                    if let about = community.socialAbout, !about.isEmpty {
                        MarkdownBodyView(text: about)
                            .padding(SocialSpacing.layer3)
                            .background(palette.tertiaryBackground, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(SocialSpacing.layer4)
            }
            .background(palette.background)
            .foregroundStyle(palette.foreground)
        }
    }

    #Preview {
        CommunitySidebarView(community: SocialSample.communities[0], actions: .sample)
    }
    """##
}
