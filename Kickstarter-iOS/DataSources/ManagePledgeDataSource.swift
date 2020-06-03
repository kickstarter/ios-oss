import Foundation
import KsApi
import Library
import Prelude
import UIKit

internal final class ManagePledgeDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case rewards
  }

  internal func load(project: Project, rewards: [Reward]) {
    self.clearValues()

    let values = rewards.map { reward in (project, reward) }

    self.set(
      values: values,
      cellClass: RewardTableViewCell.self,
      inSection: Section.rewards.rawValue
    )
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RewardTableViewCell, value as (Project, Reward)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
