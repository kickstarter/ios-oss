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

  // TODO: Use a separate function called `loadReplies(comments: [Comment]` to update the existing data source with replies.

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RootCommentCell, value as Comment):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
