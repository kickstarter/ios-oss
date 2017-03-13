import Library
import KsApi
import UIKit

internal final class ProfileProjectsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case emptyState
    case projects
  }

  internal func emptyState(visible: Bool, type: ProfileProjectsType) {
    self.set(values: visible ? [type] : [],
             cellClass: ProfileEmptyStateCell.self,
             inSection: Section.emptyState.rawValue)
  }

  internal func load(projects: [Project]) {
    self.set(values: projects,
             cellClass: ProfileProjectCell.self,
             inSection: Section.projects.rawValue
    )
  }

  internal func indexPath(for itemPosition: Int) -> IndexPath {
    return IndexPath(item: itemPosition, section: Section.projects.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProfileEmptyStateCell, value as ProfileProjectsType):
      cell.configureWith(value: value)
    case let (cell as ProfileProjectCell, value as Project):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
