import KsApi
import Library
import Prelude
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case comments
  }

  internal func load() {
    let section = Section.comments.rawValue
    self.clearValues(section: section)
    DemoComment.comments().forEach { comment in
      if comment.isFailed == true {
        self.appendRow(value: comment, cellClass: CommentPostFailedCell.self, toSection: section)
      } else if comment.isRemoved == true {
        self.appendRow(value: comment, cellClass: CommentRemovedCell.self, toSection: section)
      } else {
        self.appendRow(value: comment, cellClass: CommentCell.self, toSection: section)
      }
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CommentCell, comment as DemoComment):
      cell.configureWith(value: comment)
    case let (cell as CommentPostFailedCell, comment as DemoComment):
      cell.configureWith(value: comment)
    case let (cell as CommentRemovedCell, comment as DemoComment):
      cell.configureWith(value: comment)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
