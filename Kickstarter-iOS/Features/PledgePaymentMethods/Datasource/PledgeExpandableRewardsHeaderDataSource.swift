import KsApi
import Library
import Prelude
import UIKit

internal final class PledgeExpandableRewardsHeaderDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case header
    case rewards
  }

  internal func load(_ items: [PledgeExpandableRewardsHeaderItem]) {
    self.clearValues()

    let headerItemData = items.compactMap { item -> PledgeExpandableHeaderRewardCellData? in
      guard case let .header(data) = item else { return nil }
      return data
    }

    let rewardItemData = items.compactMap { item -> PledgeExpandableHeaderRewardCellData? in
      guard case let .reward(data) = item else { return nil }
      return data
    }

    self.set(
      values: headerItemData,
      cellClass: PledgeExpandableHeaderRewardHeaderCell.self,
      inSection: Section.header.rawValue
    )

    self.set(
      values: rewardItemData,
      cellClass: PledgeExpandableHeaderRewardCell.self,
      inSection: Section.rewards.rawValue
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeExpandableHeaderRewardHeaderCell, value as PledgeExpandableHeaderRewardCellData):
      cell.configureWith(value: value)
    case let (cell as PledgeExpandableHeaderRewardCell, value as PledgeExpandableHeaderRewardCellData):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
