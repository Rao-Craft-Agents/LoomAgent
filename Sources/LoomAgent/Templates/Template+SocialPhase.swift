//  WHAT: The template of `SocialPhase.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialPhase = ##"""
    import Foundation

    /// Where a list is in loading. A list with nothing in it shows a spinner, an empty state, or the error with a way
    /// to try again; a list with content shows the same at its end, and asks for more while there is more.
    enum SocialPhase: Equatable, Sendable {
        /// Nothing asked for yet, or a page arrived and there may be more.
        case idle
        /// A page is on its way.
        case loading
        /// Every page has arrived.
        case exhausted
        /// The last ask failed, and why, in a sentence the person can read.
        case failed(String)

        var isLoading: Bool { self == .loading }

        /// Whether reaching the end of the list should ask for more.
        var wantsMore: Bool { self == .idle }
    }
    """##
}
