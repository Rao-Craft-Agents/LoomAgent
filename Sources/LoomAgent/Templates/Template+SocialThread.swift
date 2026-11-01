//  WHAT: The template of `SocialThread.swift`, as the kit writes it into an app; `TemplateRender` drops the blocks a
//        call leaves out and renames the views with the call's prefix.

extension Template {
    static let socialThread = ##"""
    import Foundation

    /// A thread of comments in the order it reads: each comment followed by its replies, as deep as they go. Built from
    /// each comment's parent when the app maps one, else from the order and depth it gives; replies under a folded
    /// comment are left out.
    struct SocialThread<Comment: CommentRepresentable> {
        struct Row: Identifiable {
            let comment: Comment
            let depth: Int
            var id: Comment.ID { comment.id }
        }

        let rows: [Row]

        init(_ comments: [Comment], folded: Set<Comment.ID> = []) {
            let ids = Set(comments.map { "\($0.id)" })
            let byParent = Dictionary(grouping: comments.filter { $0.socialParentID.map(ids.contains) ?? false }) { $0.socialParentID ?? "" }
            var rows: [Row] = []
            if byParent.isEmpty {
                // No parents: the app's order and depths are the thread.
                var hiddenBelow: Int?
                for comment in comments {
                    if let depth = hiddenBelow, comment.socialDepth > depth { continue }
                    hiddenBelow = folded.contains(comment.id) ? comment.socialDepth : nil
                    rows.append(Row(comment: comment, depth: max(0, comment.socialDepth)))
                }
            } else {
                func visit(_ comment: Comment, depth: Int) {
                    rows.append(Row(comment: comment, depth: depth))
                    guard !folded.contains(comment.id) else { return }
                    for reply in byParent["\(comment.id)"] ?? [] { visit(reply, depth: depth + 1) }
                }
                for root in comments where !(root.socialParentID.map(ids.contains) ?? false) { visit(root, depth: 0) }
            }
            self.rows = rows
        }
    }
    """##
}
