import Library
import Models
import UIKit

internal final class ActivitiesDataSource: ValueCellDataSource {

  private enum Section: Int {
    case EmptyState
    case Activities
  }

  internal func emptyState(visible visible: Bool) {
    self.set(values: visible ? [()] : [],
             cellClass: ActivityEmptyStateCell.self,
             inSection: Section.EmptyState.rawValue)
  }

  internal func load(activities activities: [Activity]) {
    let section = Section.Activities.rawValue

    self.clearValues(section: section)

    activities.forEach { activity in
      switch activity.category {
      case .Backing:
        self.appendRow(value: activity, cellClass: ActivityFriendBackingCell.self, toSection: section)
      case .Update:
        self.appendRow(value: activity, cellClass: ActivityUpdateCell.self, toSection: section)
      case .Follow:
        self.appendRow(value: activity, cellClass: ActivityFriendFollowCell.self, toSection: section)
      case .Success:
        self.appendRow(value: activity, cellClass: ActivityStateChangeCell.self, toSection: section)
      default:
        assertionFailure("Unsupported activity")
      }

      self.appendStaticRow(cellIdentifier: "Padding", toSection: section)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ActivityUpdateCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ActivityFriendBackingCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ActivityFriendFollowCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ActivityStateChangeCell, activity as Activity):
      cell.configureWith(value: activity)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
