import Library
import KsApi
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case emptyState
    case comments
  }

  internal func load(comments: [Comment], project: Project, loggedInUser: User?) {
    self.set(values: comments.map { ($0, project, loggedInUser) },
             cellClass: CommentCell.self,
             inSection: Section.comments.rawValue)
  }

  internal func load(project: Project, update: Update?, visible: Bool) {
    self.set(values: visible ? [(project, update)] : [],
             cellClass: CommentsEmptyStateCell.self,
             inSection: Section.emptyState.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as CommentCell, value as (Comment, Project, User?)):
      cell.configureWith(value: value)
    case let (cell as CommentsEmptyStateCell, value as (Project, Update?)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
