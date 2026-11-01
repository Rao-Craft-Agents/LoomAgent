//  WHAT: The template of `FeedHeaderView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let feedHeaderView = ##"""
    import SwiftUI

    /// The top of a feed, as Loom draws it: where it is from in small type, its title in large bold type, then its
    /// menus (how it is sorted, which posts it lists) in the accent colour, with a spinner while it loads and a slot
    /// at the end for the app (the account, a search button).
    struct FeedHeaderView<Accessory: View>: View {
        var title: Text?
        var subtitle: Text?
        var menus: [SocialMenu] = []
        var phase: SocialPhase = .idle
        /// Asks again when loading failed.
        var retry: (@MainActor () async -> Void)? = nil
        @ViewBuilder var accessory: () -> Accessory

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            VStack(alignment: .leading, spacing: 0) {
                if let subtitle {
                    subtitle
                        .font(.footnote)
                        .lineLimit(1)
                }
                if let title {
                    title
                        .font(.title.bold())
                        .lineLimit(2)
                        .padding(.bottom, SocialSpacing.layer1)
                        .accessibilityAddTraits(.isHeader)
                }
                HStack(spacing: SocialSpacing.layer4) {
                    ForEach(menus.indices, id: \.self) { index in
                        SocialMenuButton(menu: menus[index])
                    }
                    Spacer(minLength: 0)
                    switch phase {
                    case .loading:
                        ProgressView()
                            .controlSize(.small)
                    case .failed:
                        if let retry {
                            Button { Task { await retry() } } label: {
                                Image(systemName: "arrow.counterclockwise").font(.headline.bold())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("Try again"))
                        }
                    case .idle, .exhausted:
                        EmptyView()
                    }
                    accessory()
                }
                .padding(.vertical, SocialSpacing.layer2)
            }
            .foregroundStyle(palette.foreground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, SocialSpacing.layer4)
            .padding(.top, SocialSpacing.layer3)
            .padding(.bottom, SocialSpacing.layer2)
        }
    }

    extension FeedHeaderView where Accessory == EmptyView {
        init(title: Text?, subtitle: Text? = nil, menus: [SocialMenu] = [], phase: SocialPhase = .idle,
             retry: (@MainActor () async -> Void)? = nil) {
            self.init(title: title, subtitle: subtitle, menus: menus, phase: phase, retry: retry) { EmptyView() }
        }
    }

    private struct FeedHeaderPreview: View {
        @State private var sort = "Hot"
        @State private var listing = "All"

        var body: some View {
            FeedHeaderView(title: Text("Front Page"), subtitle: Text(verbatim: "kitchen.social"),
                           menus: [
                               SocialMenu("Sort", selection: $sort, options: ["Hot", "New", "Top"], title: { LocalizedStringKey($0) }),
                               SocialMenu("Show", selection: $listing, options: ["All", "Local", "Subscribed"], title: { LocalizedStringKey($0) }),
                           ],
                           phase: .loading) {
                Text(verbatim: "@maria").font(.headline.bold())
            }
        }
    }

    #Preview {
        FeedHeaderPreview()
    }
    """##
}
