//  WHAT: The template of `SocialSwipe.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialSwipe = ##"""
    import SwiftUI

    /// Loom's swipe: drag a card toward its leading edge to reveal an action behind it, and let go past the mark to
    /// take it. A horizontal drag only, so a list still scrolls; VoiceOver gets the same action by name.
    struct SocialSwipe: ViewModifier {
        var systemImage: String
        var tint: Color
        var label: LocalizedStringKey
        var action: () -> Void

        @State private var offset: CGFloat = 0
        @State private var armed = false
        private let mark: CGFloat = 80

        func body(content: Content) -> some View {
            content
                .offset(x: offset)
                .background(alignment: .trailing) {
                    ZStack {
                        tint
                        Image(systemName: systemImage)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .scaleEffect(armed ? 1.15 : 1)
                    }
                    .frame(width: max(0, -offset))
                    .opacity(offset < 0 ? 1 : 0)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            guard abs(value.translation.width) > abs(value.translation.height) * 1.5 else { return }
                            offset = min(0, value.translation.width)
                            armed = -offset > mark
                        }
                        .onEnded { _ in
                            if armed { action() }
                            withAnimation(.interactiveSpring()) { offset = 0 }
                            armed = false
                        })
                .animation(.interactiveSpring(), value: armed)
                .sensoryFeedback(.impact, trigger: armed) { _, isArmed in isArmed }
                .accessibilityAction(named: Text(label), action)
        }
    }

    extension View {
        /// Reveals `systemImage` on `tint` when the view is dragged toward its leading edge, and calls `action` past the mark.
        func socialSwipe(systemImage: String, tint: Color, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
            modifier(SocialSwipe(systemImage: systemImage, tint: tint, label: label, action: action))
        }
    }
    """##
}
