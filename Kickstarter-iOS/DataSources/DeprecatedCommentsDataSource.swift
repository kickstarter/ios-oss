import KsApi
import Library
import UIKit

internal final class DeprecatedCommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case emptyState
    case comments
  }

  internal func load(
    comments: [DeprecatedComment],
    project: Project,
    update: Update?,
    loggedInUser: User?,
    shouldShowEmptyState: Bool
  ) {
    if comments.isEmpty {
      self.set(
        values: shouldShowEmptyState ? [(project, update)] : [],
        cellClass: DeprecatedCommentsEmptyStateCell.self,
        inSection: Section.emptyState.rawValue
      )
    } else {
      self.set(
        values: comments.map { ($0, project, loggedInUser) },
        cellClass: DeprecatedCommentCell.self,
        inSection: Section.comments.rawValue
      )
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DeprecatedCommentCell, value as (DeprecatedComment, Project, User?)):
      cell.configureWith(value: value)
    case let (cell as DeprecatedCommentsEmptyStateCell, value as (Project, Update?)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
