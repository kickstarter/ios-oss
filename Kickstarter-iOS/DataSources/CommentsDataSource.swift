import KsApi
import Library
import Prelude
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case comments
    case empty
  }

  internal func load(comments: [Comment], project: Project) {
    let section = !comments.isEmpty ? Section.comments.rawValue : Section.empty.rawValue
    self.clearValues(section: section)

    guard !comments.isEmpty else {
      self.appendRow(
        value: (),
        cellClass: EmptyCommentsCell.self,
        toSection: section
      )

      return
    }

    comments.forEach { comment in
      guard comment.isDeleted == false else {
        self.appendRow(
          value: comment,
          cellClass: CommentRemovedCell.self,
          toSection: section
        )
        return
      }

      switch comment.status {
      case .failed, .retrying:
        self.appendRow(
          value: comment,
          cellClass: CommentPostFailedCell.self,
          toSection: section
        )
      case .success, .retrySuccess:
        self.appendRow(value: (comment, project), cellClass: CommentCell.self, toSection: section)
      case .unknown:
        assertionFailure("Comments that have not had their state set should not be added to the data source.")
      }
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CommentCell, value as (Comment, Project)):
      cell.configureWith(value: value)
    case let (cell as CommentPostFailedCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as CommentRemovedCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as EmptyCommentsCell, _):
      cell.configureWith(value: ())
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }

  public func comment(at indexPath: IndexPath) -> Comment? {
    let value = self[indexPath]

    switch value {
    case let value as Comment: return value
    case let value as (comment: Comment, project: Project): return value.comment
    default: return nil
    }
  }
}
