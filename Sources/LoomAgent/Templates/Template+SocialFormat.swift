//  WHAT: The template of `SocialFormat.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialFormat = ##"""
    import Foundation

    /// How the social views say a time and a count.
    enum SocialFormat {
        /// `44 min. ago`, `2 days ago`, in the person's language.
        static func relative(_ date: Date, now: Date = .now) -> String {
            date.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated))
        }

        /// `999`, `1.2K`, `3.4M`, in the person's language.
        static func count(_ value: Int) -> String {
            value.formatted(.number.notation(.compactName))
        }
    }
    """##
}
