import Library
import Models
import UIKit

internal final class ActivitiesDataSource: ValueCellDataSource {
  func loadData(activities: [Activity]) {
    self.clearValues()

    activities.forEach { activity in
      switch activity.category {
      case .Backing:
        self.appendSection(
          values: [activity],
          cellClass: ActivityFriendBackingCell.self
        )
      case .Update:
        self.appendSection(
          values: [activity],
          cellClass: ActivityUpdateCell.self
        )
      case .Follow:
        self.appendSection(
          values: [activity],
          cellClass: ActivityFriendFollowCell.self
        )
      case .Success:
        self.appendSection(
          values: [activity],
          cellClass: ActivityStateChangeCell.self
        )
      default:
        assertionFailure("Unsupported activity")
      }
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
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
