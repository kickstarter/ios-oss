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

  internal func load(activities activities: [Activity]) {
    let section = Section.activities.rawValue

    self.clearValues(section: section)

    activities.forEach { activity in
      switch activity.category {
      case .backing, .backingAmount, .backingCanceled, .backingDropped, .backingReward:
        self.appendRow(value: activity, cellClass: ProjectActivityBackingCell.self, toSection: section)
      case .cancellation, .failure, .suspension:
        self.appendRow(
          value: activity, cellClass: ProjectActivityNegativeStateChangeCell.self, toSection: section)
      case .commentPost:
        self.appendRow(value: activity, cellClass: ProjectActivityUpdateCommentCell.self, toSection: section)
      case .commentProject:
        self.appendRow(value: activity, cellClass: ProjectActivityProjectCommentCell.self, toSection: section)
      case .launch:
        self.appendRow(value: activity, cellClass: ProjectActivityLaunchCell.self, toSection: section)
      case .success:
        self.appendRow(value: activity, cellClass: ProjectActivitySuccessCell.self, toSection: section)
      case .update:
        self.appendRow(value: activity, cellClass: ProjectActivityUpdateCell.self, toSection: section)
      default:
        assertionFailure("Unsupported activity: \(activity)")
      }

      self.appendStaticRow(cellIdentifier: "Padding", toSection: section)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ProjectActivityBackingCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ProjectActivityEmptyStateCell, value as Void):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityLaunchCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ProjectActivityNegativeStateChangeCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ProjectActivityProjectCommentCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ProjectActivitySuccessCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ProjectActivityUpdateCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ProjectActivityUpdateCommentCell, activity as Activity):
      cell.configureWith(value: activity)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
