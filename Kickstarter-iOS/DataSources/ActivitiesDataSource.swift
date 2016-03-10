import class Library.MVVMDataSource
import struct Models.Activity
import class UIKit.UITableView
import class UIKit.UITableViewCell

internal final class ActivitiesDataSource: MVVMDataSource {

  func loadData(activities: [Activity]) {

    self.clearData()

    activities.forEach { activity in
      switch activity.category {
      case .Backing:
        self.appendSectionData(
          [ActivityFriendBackingViewModel(activity: activity)],
          cellClass: ActivityFriendBackingCell.self
        )
      case .Update:
        self.appendSectionData(
          [ActivityUpdateViewModel(activity: activity)],
          cellClass: ActivityUpdateCell.self
        )
      case .Follow:
        self.appendSectionData(
          [ActivityFriendFollowViewModel(activity: activity)],
          cellClass: ActivityFriendFollowCell.self
        )
      case .Success:
        self.appendSectionData(
          [ActivityStateChangeViewModel(activity: activity)],
          cellClass: ActivityStateChangeCell.self
        )
      default:
        assertionFailure("Unsupported activity")
      }
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withViewModel viewModel: AnyObject) {

    switch (cell, viewModel) {
    case let (cell as ActivityUpdateCell, viewModel as ActivityUpdateViewModel):
      cell.viewModelProperty.value = viewModel
    case let (cell as ActivityFriendBackingCell, viewModel as ActivityFriendBackingViewModel):
      cell.viewModelProperty.value = viewModel
    case let (cell as ActivityFriendFollowCell, viewModel as ActivityFriendFollowViewModel):
      cell.viewModelProperty.value = viewModel
    case let (cell as ActivityStateChangeCell, viewModel as ActivityStateChangeViewModel):
      cell.viewModelProperty.value = viewModel
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
