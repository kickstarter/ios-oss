import Library
import KsApi
import UIKit

internal final class ProjectActivitiesDataSource: ValueCellDataSource {

  private enum Section: Int {
    case emptyState
    case activities
  }

  internal func emptyState(visible visible: Bool) {
    self.set(values: visible ? [()] : [],
             cellClass: ProjectActivityEmptyStateCell.self,
             inSection: Section.emptyState.rawValue)
  }

  internal func load(activities activities: [Activity], project: Project) {
    let section = Section.activities.rawValue

    self.clearValues(section: section)

    activities.forEach { activity in
      switch activity.category {
      case .backing, .backingAmount, .backingCanceled, .backingReward:
        self.appendRow(
          value: (activity, project),
          cellClass: ProjectActivityBackingCell.self,
          toSection: section
        )
      case .cancellation, .failure, .suspension:
        self.appendRow(
          value: (activity, project),
          cellClass: ProjectActivityNegativeStateChangeCell.self,
          toSection: section
        )
      case .commentPost, .commentProject:
        self.appendRow(
          value: (activity, project),
          cellClass: ProjectActivityCommentCell.self,
          toSection: section
        )
      case .launch:
        self.appendRow(
          value: (activity, project),
          cellClass: ProjectActivityLaunchCell.self,
          toSection: section
        )
      case .success:
        self.appendRow(
          value: (activity, project),
          cellClass: ProjectActivitySuccessCell.self,
          toSection: section
        )
      case .update:
        self.appendRow(
          value: (activity, project),
          cellClass: ProjectActivityUpdateCell.self,
          toSection: section
        )
      case .backingDropped, .follow, .funding, .watch, .unknown:
        assertionFailure("Unsupported activity: \(activity)")
      }
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ProjectActivityBackingCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityCommentCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityEmptyStateCell, value as Void):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityLaunchCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityNegativeStateChangeCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivitySuccessCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityUpdateCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
