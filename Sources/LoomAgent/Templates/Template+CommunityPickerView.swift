//  WHAT: The template of `CommunityPickerView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let communityPickerView = ##"""
    import SwiftUI

    /// A list of communities to choose from, as Loom's sidebar and picker show them: which list it is (subscribed,
    /// local, all) in large tab words with a refresh beside them, then one card a community. A tap picks the
    /// community when the view is a picker, and opens it otherwise.
    struct CommunityPickerView<Social: SocialSchema>: View {
        var communities: [Social.Community]
        var phase: SocialPhase = .idle
        /// Which list is shown, when the app offers several.
        var scope: SocialMenu? = nil
        var actions: SocialActions<Social>
        /// Picks a community; when left out, a tap opens the community.
        var pick: ((Social.Community) -> Void)? = nil

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            VStack(spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: SocialSpacing.layer4) {
                    if let scope {
                        ForEach(scope.options.indices, id: \.self) { index in
                            Button { scope.select(index) } label: {
                                Text(scope.options[index].title)
                                    .font(index == scope.selected ? .title2.bold() : .title3.bold())
                                    .opacity(index == scope.selected ? 1 : 0.6)
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(index == scope.selected ? .isSelected : [])
                        }
                    } else {
                        Text("Communities").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                    }
                    if let refresh = actions.refresh {
                        Button { Task { await refresh() } } label: {
                            Image(systemName: "arrow.counterclockwise").font(.subheadline.bold())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Refresh"))
                    }
                    Spacer(minLength: 0)
                }
                .foregroundStyle(palette.foreground)
                .padding(.horizontal, SocialSpacing.layer4)
                .padding(.vertical, SocialSpacing.layer3)
                Divider()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if communities.isEmpty {
                            ContentStateView(phase: phase, empty: "No communities", retry: actions.refresh)
                        } else {
                            ForEach(communities) { community in
                                CommunityCardView(community: community, actions: picking, showsCounts: pick == nil)
                                    .padding(SocialSpacing.layer3)
                                Divider().padding(.leading, SocialSpacing.layer3)
                            }
                            ContentStateView(phase: phase, empty: "No communities", retry: actions.loadMore, isFooter: true)
                                .task(id: communities.count) {
                                    if phase.wantsMore { await actions.loadMore?() }
                                }
                        }
                    }
                }
            }
            .background(palette.background)
        }

        /// The app's actions, with opening a community turned into picking it when this is a picker.
        private var picking: SocialActions<Social> {
            guard let pick else { return actions }
            var actions = self.actions
            actions.openCommunity = { target in
                if case .community(let community) = target { pick(community) }
            }
            return actions
        }
    }

    private struct CommunityPickerPreview: View {
        @State private var list = "Subscribed"

        var body: some View {
            CommunityPickerView(communities: SocialSample.communities, phase: .exhausted,
                                scope: SocialMenu("List", selection: $list, options: ["Subscribed", "Local", "All"], title: { LocalizedStringKey($0) }),
                                actions: .sample)
        }
    }

    #Preview {
        CommunityPickerPreview()
    }
    """##
}
