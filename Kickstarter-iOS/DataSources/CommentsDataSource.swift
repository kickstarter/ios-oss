import Library
import KsApi
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case EmptyState
    case Comments
  }

  internal func load(comments comments: [Comment], project: Project, loggedInUser: User?) {
    self.set(values: comments.map { ($0, project, loggedInUser) },
             cellClass: CommentCell.self,
             inSection: Section.Comments.rawValue)
  }

  internal func load(project project: Project, update: Update?) {
    self.set(values: [(project, update)],
             cellClass: CommentsEmptyStateCell.self,
             inSection: Section.EmptyState.rawValue
    )
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
