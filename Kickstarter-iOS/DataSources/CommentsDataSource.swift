import Library
import KsApi
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case emptyState
    case comments
  }

  internal func load(comments: [Comment],
                     project: Project,
                     update: Update?,
                     loggedInUser: User?,
                     shouldShowEmptyState: Bool) {

    if comments.isEmpty {
      self.set(values: shouldShowEmptyState ? [(project, update)] : [],
              cellClass: CommentsEmptyStateCell.self,
              inSection: Section.emptyState.rawValue)
    } else {
      self.set(values: comments.map { ($0, project, loggedInUser) } ,
             cellClass: CommentCell.self,
             inSection: Section.comments.rawValue)
    }
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
