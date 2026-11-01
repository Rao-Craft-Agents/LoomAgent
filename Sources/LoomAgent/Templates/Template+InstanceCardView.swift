//  WHAT: The template of `InstanceCardView.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let instanceCardView = ##"""
    import SwiftUI

    /// A server of a federated network, as Loom's explore view shows it: its name and address over its banner, what
    /// it says about itself, then a button to connect (marked once connected), a star, and how fast it answered as
    /// bars that are green, yellow or red.
    struct InstanceCardView<Social: SocialSchema>: View {
        var instance: Social.Instance
        var actions: SocialActions<Social>

        @Environment(\.socialStyle) private var style

        var body: some View {
            let palette = style.palette
            let hasBanner = instance.socialBanner != nil
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: hasBanner ? SocialSpacing.layer1 : 0) {
                        Text(verbatim: instance.socialName.isEmpty ? instance.socialDomain : instance.socialName)
                            .font(.headline.bold())
                            .lineLimit(1)
                        Text(verbatim: instance.socialDomain)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    if let source = instance.socialSource {
                        Text(verbatim: source).font(.footnote).foregroundStyle(palette.accent)
                    } else {
                        AvatarView(url: instance.socialIcon, size: .mini, kind: .community)
                    }
                }
                .padding(.horizontal, SocialSpacing.layer3)
                .padding(.top, SocialSpacing.layer2)

                if let about = instance.socialAbout, !about.isEmpty {
                    ScrollView {
                        MarkdownBodyView(text: about, font: .footnote)
                            .padding(SocialSpacing.layer3)
                    }
                    .frame(maxHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(palette.secondaryBackground.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, SocialSpacing.layer3)
                    .padding(.top, SocialSpacing.layer2)
                }

                Divider().padding(.vertical, SocialSpacing.layer2)

                HStack(spacing: SocialSpacing.layer3) {
                    if let connect = actions.connect {
                        Button { if !instance.socialIsConnected { connect(instance) } } label: {
                            Group {
                                if instance.socialIsConnected { Text("Connected") } else { Text("Connect") }
                            }
                            .font(.headline.bold())
                            .foregroundStyle(Color(white: 0.07))
                            .padding(.horizontal, SocialSpacing.layer3)
                            .padding(.vertical, SocialSpacing.layer1)
                            .background(instance.socialIsConnected ? palette.connected : palette.connect,
                                        in: RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                    if let favorite = actions.favorite {
                        Button { favorite(instance) } label: {
                            Image(systemName: instance.socialIsFavorite ? "star.fill" : "star")
                                .foregroundStyle(instance.socialIsFavorite ? palette.connect : palette.foreground)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(instance.socialIsFavorite ? Text("Unstar") : Text("Star"))
                    }
                    Spacer(minLength: 0)
                    LatencyBars(seconds: instance.socialLatency)
                }
                .padding(.horizontal, SocialSpacing.layer3)
                .padding(.bottom, SocialSpacing.layer2)
            }
            .foregroundStyle(palette.foreground)
            .frame(minWidth: 200, minHeight: 100)
            .background {
                if hasBanner {
                    BannerView(url: instance.socialBanner, height: 200)
                        .overlay(palette.background.opacity(0.6))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.secondaryForeground.opacity(0.75), lineWidth: 1))
        }
    }

    /// How fast a server answered: the time and three bars, green under a second, yellow under three, red after or
    /// when it did not answer.
    struct LatencyBars: View {
        var seconds: Double?

        var body: some View {
            let color: Color = {
                guard let seconds else { return .red }
                return seconds > 3 ? .red : seconds > 1 ? .yellow : .green
            }()
            HStack(alignment: .bottom, spacing: 2) {
                Group {
                    if let seconds {
                        Text("\(Int(seconds * 1000)) ms")
                    } else {
                        Text(verbatim: "~")
                    }
                }
                .font(.headline.bold())
                .padding(.trailing, SocialSpacing.layer2)
                ForEach([6, 10, 16], id: \.self) { height in
                    Rectangle().fill(color).frame(width: 4, height: CGFloat(height))
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(seconds.map { Text("Answered in \(Int($0 * 1000)) milliseconds") } ?? Text("Not answering"))
        }
    }

    #Preview {
        VStack(spacing: SocialSpacing.layer4) {
            ForEach(SocialSample.instances) { instance in
                InstanceCardView(instance: instance, actions: SocialActions<SocialSample>.sample)
            }
        }
        .padding()
    }
    """##
}
