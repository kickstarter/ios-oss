import Library
import UIKit

public enum PledgeRewardsSummarySection: CaseIterable {
  case header
  case reward
  case addOns
  case bonusSupport
}

enum PledgeRewardsSummaryRow: Hashable {
  case header(PledgeSummaryRewardCellData)
  case reward(PledgeSummaryRewardCellData)
  case addOns(PledgeSummaryRewardCellData)
  case bonusSupport(PledgeSummaryRewardCellData)
}

/**
 A `UITableViewDiffableDataSource` that accepts two types.

 - `PledgeRewardsSummarySection`: defines the section type of the table.
 - `PledgeRewardsSummaryRow`: the model that represents the data to be displayed in each cell.

 These types are defined above and each UITableViewCell is configured based on the row being rendered.
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
      case let .reward(model), let .addOns(model), let .bonusSupport(model):
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

/**
 Creates `NSDiffableDataSourceSnapshot` to apply to the pledge summary table view data source on our crowdfunding and late pledge checkout screens.

 - parameter headerData: The `PledgeExpandableHeaderRewardCellData`that represents the table's custom header `UITableViewCell`.
 - parameter rewards: The `[PledgeExpandableHeaderRewardCellData]`that represents the tables reward data (baseReward, addOns, and bonusSupport).

 - returns: A `NSDiffableDataSourceSnapshot` that will be applied to the UITableView's Diffable Data Source `NoShippingPledgeRewardsSummaryDiffableDataSource`.
 */

func diffableDataSourceSnapshot(
  using headerData: PledgeSummaryRewardCellData?,
  _ rewards: [PledgeSummaryRewardCellData]
)
  -> NSDiffableDataSourceSnapshot<PledgeRewardsSummarySection, PledgeRewardsSummaryRow> {
  var snapshot = NSDiffableDataSourceSnapshot<PledgeRewardsSummarySection, PledgeRewardsSummaryRow>()

  // MARK: Header

  /// Define the sections of the table and what data to use in each section.
  if let header = headerData {
    snapshot.appendSections([.header])
    snapshot.appendItems([.header(header)], toSection: .header)
  }

  // MARK: Reward

  if let baseReward = rewards.first {
    snapshot.appendSections([.reward])
    snapshot.appendItems([.reward(baseReward)], toSection: .reward)
  }

  // MARK: Add-Ons

  let addOnsData = rewards
    .filter { reward in reward != rewards.first && reward.text != Strings.Bonus_support() }
    .map { PledgeRewardsSummaryRow.addOns($0) }

  /// We only want to add an add-ons section if any have been selected
  if addOnsData.count > 0 {
    snapshot.appendSections([.addOns])
    snapshot.appendItems(addOnsData, toSection: .addOns)
  }

  // MARK: Bonus Support

  let bonusSupport = rewards
    .filter { reward in reward.text == Strings.Bonus_support() }
    .map { PledgeRewardsSummaryRow.bonusSupport($0) }

  if let bonusSupportData = bonusSupport.first {
    snapshot.appendSections([.bonusSupport])
    snapshot.appendItems([bonusSupportData], toSection: .bonusSupport)
  }

  return snapshot
}
