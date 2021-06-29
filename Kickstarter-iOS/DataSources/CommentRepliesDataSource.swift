import KsApi
import Library
import Prelude
import UIKit

internal final class CommentRepliesDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case comment
    case replies
  }

  internal func createContext(comment: Comment) {
    let section = Section.comment.rawValue
    self.clearValues()

    self.appendRow(value: comment, cellClass: RootCommentCell.self, toSection: section)
  }

  internal func load(replies: [Comment], project: Project) {
    replies.forEach { reply in
      self.appendRow(
        value: (reply, project),
        cellClass: CommentCell.self,
        toSection: Section.replies.rawValue
      )
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RootCommentCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as CommentCell, value as (Comment, Project)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
