import KsApi
import Library
import Prelude
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case comments
    case empty
  }

  internal func load(comments: [Comment], loggedInUser: User?) {
    let section = Section.comments.rawValue
    self.clearValues(section: section)
    comments.forEach { comment in
      switch comment.status {
      case .failed:
        self
          .appendRow(
            value: (comment, loggedInUser),
            cellClass: CommentPostFailedCell.self,
            toSection: section
          )
      case .removed:
        self.appendRow(value: (comment, loggedInUser), cellClass: CommentRemovedCell.self, toSection: section)
      case .success:
        self.appendRow(value: (comment, loggedInUser), cellClass: CommentCell.self, toSection: section)
      }
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CommentCell, value as (Comment, User?)):
      cell.configureWith(value: value)
    case let (cell as CommentPostFailedCell, value as (Comment, User?)):
      cell.configureWith(value: value)
    case let (cell as CommentRemovedCell, value as (Comment, User?)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
