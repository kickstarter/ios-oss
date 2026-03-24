import KsApi
import Library
import UIKit

internal final class BackerDashboardProjectsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case emptyState
    case projects
  }

  internal func emptyState(visible: Bool, projectsType: ProfileProjectsType) {
    self.set(
      values: visible ? [projectsType] : [],
      cellClass: BackerDashboardEmptyStateCell.self,
      inSection: Section.emptyState.rawValue
    )
  }

  internal func load(projects: [ProjectCardProperties]) {
    self.set(
      values: projects.map { $0.projectCellModel },
      cellClass: BackerDashboardProjectCell.self,
      inSection: Section.projects.rawValue
    )
  }

  internal func indexPath(for row: Int) -> IndexPath {
    return IndexPath(row: row, section: Section.projects.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as BackerDashboardEmptyStateCell, value as ProfileProjectsType):
      cell.configureWith(value: value)
    case let (
      cell as BackerDashboardProjectCell,
      value as BackerDashboardProjectCellViewModel.ProjectCellModel
    ):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
