import Library
import Models
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case BackerEmptyState
    case NonBackerEmptyState
    case LoggedOutEmptyState
    case Comments
  }

  internal func load(comments comments: [Comment], project: Project, loggedInUser: User?) {
    self.set(values: comments.map { ($0, project, loggedInUser) },
             cellClass: CommentCell.self,
             inSection: Section.Comments.rawValue)
  }

  internal func backerEmptyState(visible visible: Bool) {
    self.set(cellIdentifiers: visible ? ["BackerEmptyState"] : [],
             inSection: Section.BackerEmptyState.rawValue)
  }

  internal func nonBackerEmptyState(visible visible: Bool) {
    self.set(cellIdentifiers: visible ? ["NonBackerEmptyState"] : [],
             inSection: Section.NonBackerEmptyState.rawValue)
  }

  internal func loggedOutEmptyState(visible visible: Bool) {
    self.set(cellIdentifiers: visible ? ["LoggedOutEmptyState"] : [],
             inSection: Section.LoggedOutEmptyState.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as CommentCell, value as (Comment, Project, User?)):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
