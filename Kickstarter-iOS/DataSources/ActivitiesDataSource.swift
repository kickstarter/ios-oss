import class Library.MVVMDataSource
import struct Models.Activity
import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell

internal final class ActivitiesDataSource: MVVMDataSource {

  func loadData(activities: [Activity]) {

    self.clearData()

    activities.forEach { activity in
      switch activity.category {
      case .Backing:
        self.appendRowData(
          ActivityFriendBackingViewModel(activity: activity),
          cellClass: ActivityFriendBackingCell.self,
          toSection: 0
        )
      case .Update:
        self.appendRowData(
          ActivityUpdateViewModel(activity: activity),
          cellClass: ActivityUpdateCell.self,
          toSection: 0
        )
      case .Follow:
        self.appendRowData(
          ActivityFriendFollowViewModel(activity: activity),
          cellClass: ActivityFriendFollowCell.self,
          toSection: 0
        )
      case .Success:
        self.appendRowData(
          ActivityStateChangeViewModel(activity: activity),
          cellClass: ActivityStateChangeCell.self,
          toSection: 0
        )
      default:
        assertionFailure("Unsupported activity")
      }
    }
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withViewModel viewModel: AnyObject) {

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
