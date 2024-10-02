import Library
import UIKit

public enum PledgeRewardsSummarySection: CaseIterable {
  case header
  case reward
  case addOns
}

enum PledgeRewardsSummaryRow: Hashable {
  case header(PledgeExpandableHeaderRewardCellData)
  case reward(PledgeExpandableHeaderRewardCellData)
  case addOns(PledgeExpandableHeaderRewardCellData)
}

class NoShippingPledgeRewardsSummaryDiffableDataSource: UITableViewDiffableDataSource<
  PledgeRewardsSummarySection,
  PledgeRewardsSummaryRow
>, UITableViewDelegate {
  init(tableView: UITableView) {
    super.init(tableView: tableView) { tableView, indexPath, item in
      switch item {
      case let .header(model):
        let cell = tableView.dequeueReusableCell(
          withClass: PostCampaignPledgeRewardsSummaryHeaderCell.self,
          for: indexPath
        ) as! PostCampaignPledgeRewardsSummaryHeaderCell

        cell.configureWith(value: model)

        return cell
      case let .reward(model):
        let cell = tableView.dequeueReusableCell(
          withClass: PostCampaignPledgeRewardsSummaryCell.self,
          for: indexPath
        ) as! PostCampaignPledgeRewardsSummaryCell

        cell.configureWith(value: model)

        return cell
      case let .addOns(model):
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
