import Library
import UIKit

public enum PledgeRewardsSummarySection: CaseIterable {
  case header
  case reward
  case addOns
  case shipping
  case bonusSupport
}

enum PledgeRewardsSummaryRow: Hashable {
  case header(PledgeExpandableHeaderRewardCellData)
  case reward(PledgeExpandableHeaderRewardCellData)
  case addOns(PledgeExpandableHeaderRewardCellData)
  case shipping(PledgeExpandableHeaderRewardCellData)
  case bonusSupport(PledgeExpandableHeaderRewardCellData)
}

/**
 A `UITableViewDiffableDataSource` that accepts two types.
 - `PledgeRewardsSummarySection`: defines the section type of the table.
 - `PledgeRewardsSummaryRow`: the model that represents the data to be displayed in each cell.
 These types are defined above and each UITableViewCell is configured based on the current row being rendered.
 */

class NoShippingPledgeRewardsSummaryDiffableDataSource: UITableViewDiffableDataSource<
  PledgeRewardsSummarySection,
  PledgeRewardsSummaryRow
> {
  init(tableView: UITableView) {
    super.init(tableView: tableView) { tableView, indexPath, row in
      switch row {
      case let .header(model):
        let cell = tableView.dequeueReusableCell(
          withClass: PostCampaignPledgeRewardsSummaryHeaderCell.self,
          for: indexPath
        ) as! PostCampaignPledgeRewardsSummaryHeaderCell

        cell.configureWith(value: model)

        return cell
      case let .reward(model), let .addOns(model), let .shipping(model), let .bonusSupport(model):
        let cell = tableView.dequeueReusableCell(
          withClass: PostCampaignPledgeRewardsSummaryCell.self,
          for: indexPath
        ) as! PostCampaignPledgeRewardsSummaryCell

        cell.configureWith(value: model)

        return cell
      }
    }
  }
}
