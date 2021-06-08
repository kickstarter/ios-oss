import KsApi
import Library
import Prelude
import UIKit

internal final class CommentRepliesDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case comment
    case replies
  }

  internal func load(comment: Comment) {
    let section = Section.comment.rawValue
    self.clearValues()

    self
      .appendRow(value: (comment, nil), cellClass: CommentCell.self, toSection: section)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CommentCell, value as Comment):
      cell.configureAsRootWith(comment: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
