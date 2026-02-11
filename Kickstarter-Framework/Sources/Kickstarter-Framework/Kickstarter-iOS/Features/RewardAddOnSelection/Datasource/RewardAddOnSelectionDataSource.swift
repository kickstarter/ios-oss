import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class RewardAddOnSelectionDataSource: ValueCellDataSource {
  private enum Section: Int {
    case rewardAddOns
    case emptyState
  }

  func load(_ values: [RewardAddOnSelectionDataSourceItem]) {
    self.clearValues()

    let rewardAddOns = values.compactMap(\.rewardAddOnCardViewData)

    if !rewardAddOns.isEmpty {
      self.set(
        values: rewardAddOns,
        cellClass: RewardAddOnCell.self,
        inSection: Section.rewardAddOns.rawValue
      )
    } else {
      let emptyStateViewTypes = values.compactMap(\.emptyStateViewType)

      self.set(
        values: emptyStateViewTypes,
        cellClass: EmptyStateCell.self,
        inSection: Section.emptyState.rawValue
      )
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RewardAddOnCell, value as RewardAddOnCardViewData):
      cell.configureWith(value: value)
    case let (cell as EmptyStateCell, value as EmptyStateViewType):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }

  func isEmptyStateIndexPath(_ indexPath: IndexPath) -> Bool {
    return indexPath.section == Section.emptyState.rawValue
  }
}
