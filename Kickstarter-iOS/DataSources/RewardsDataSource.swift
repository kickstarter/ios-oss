import KsApi
import Library

internal final class RewardsDataSource: ValueCellDataSource {

  internal func load(project project: Project) {
    let rewards = project.rewards
      .filter { $0.id != 0 }
      .sort()
      .map { (project, $0) }

    self.set(values: rewards, cellClass: RewardCell.self, inSection: 0)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as RewardCell, value as (Project, Reward)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (\(cell.dynamicType), \(value.dynamicType)) combo.")
    }
  }
}
