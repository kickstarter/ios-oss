import KsApi
import Library
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case comments
    case empty
  }

  internal func updateCommentsSection(
    comments: [Comment]) {
    self.set(
      values: comments,
      cellClass: CommentCell.self,
      inSection: Section.comments.rawValue
    )
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CommentCell, value as Comment):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
