import Foundation
import Library
import KsApi

internal final class DashboardDataSource: ValueCellDataSource {
  private enum Section: Int {
    case Context
    case Action
    case FundingProgress
    case Rewards
    case Referrers
    case Video
  }

  internal func load(project project: Project) {
    self.clearValues()

    self.set(values: [project], cellClass: DashboardContextCell.self, inSection: Section.Context.rawValue)

    self.set(values: [project], cellClass: DashboardActionCell.self, inSection: Section.Action.rawValue)
  }

  internal func load(fundingDateStats stats: [ProjectStatsEnvelope.FundingDateStats], project: Project) {
    self.appendRow(
      value: (stats, project),
      cellClass: DashboardFundingCell.self,
      toSection: Section.FundingProgress.rawValue
    )
  }

  internal func load(cumulative cumulative: ProjectStatsEnvelope.CumulativeStats,
                                project: Project,
                                referrers: [ProjectStatsEnvelope.ReferrerStats]) {

    self.set(values: [(cumulative, project, referrers)], cellClass: DashboardReferrersCell.self,
             inSection: Section.Referrers.rawValue)
  }

  internal func load(rewardStats rewardStats: [ProjectStatsEnvelope.RewardStats],
                                 project: Project) {

    self.set(values: [(rewardStats: rewardStats, project: project)], cellClass: DashboardRewardsCell.self,
             inSection: Section.Rewards.rawValue)
  }

  internal func load(videoStats videoStats: ProjectStatsEnvelope.VideoStats) {
    self.set(values: [videoStats], cellClass: DashboardVideoCell.self, inSection: Section.Video.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DashboardContextCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as DashboardActionCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as DashboardFundingCell, value as ([ProjectStatsEnvelope.FundingDateStats], Project)):
      cell.configureWith(value: value)
    case let (cell as DashboardReferrersCell, value as (ProjectStatsEnvelope.CumulativeStats, Project,
      [ProjectStatsEnvelope.ReferrerStats])):
        cell.configureWith(value: value)
    case let (cell as DashboardVideoCell, value as ProjectStatsEnvelope.VideoStats):
      cell.configureWith(value: value)
    case let (
      cell as DashboardRewardsCell,
      value as ([ProjectStatsEnvelope.RewardStats], Project)
      ):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized (\(cell.dynamicType), \(value.dynamicType)) combo.")
    }
  }

  internal func didSelectContext(at indexPath: NSIndexPath) -> Bool {
    return indexPath.section == Section.Context.rawValue
  }
}
