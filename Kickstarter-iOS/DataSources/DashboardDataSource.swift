import Foundation
import Library
import KsApi

internal final class DashboardDataSource: ValueCellDataSource {
  fileprivate enum Section: Int {
    case context
    case action
    case fundingProgress
    case rewards
    case referrers
    case video
  }

  internal func load(project: Project) {
    self.clearValues()

    self.set(values: [project], cellClass: DashboardContextCell.self, inSection: Section.context.rawValue)

    self.set(values: [project], cellClass: DashboardActionCell.self, inSection: Section.action.rawValue)
  }

  internal func load(fundingDateStats stats: [ProjectStatsEnvelope.FundingDateStats], project: Project) {

    self.set(
      values: [(stats, project)],
      cellClass: DashboardFundingCell.self,
      inSection: Section.fundingProgress.rawValue
    )
  }

  internal func load(cumulative: ProjectStatsEnvelope.CumulativeStats,
                     project: Project,
                     aggregate: ProjectStatsEnvelope.ReferralAggregateStats,
                     referrers: [ProjectStatsEnvelope.ReferrerStats]) {

    self.set(values: [(cumulative, project, aggregate, referrers)], cellClass: DashboardReferrersCell.self,
             inSection: Section.referrers.rawValue)
  }

  internal func load(rewardStats: [ProjectStatsEnvelope.RewardStats],
                     project: Project) {

    self.set(values: [(rewardStats: rewardStats, project: project)], cellClass: DashboardRewardsCell.self,
             inSection: Section.rewards.rawValue)
  }

  internal func load(videoStats: ProjectStatsEnvelope.VideoStats) {
    self.set(values: [videoStats], cellClass: DashboardVideoCell.self, inSection: Section.video.rawValue)
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
      ProjectStatsEnvelope.ReferralAggregateStats, [ProjectStatsEnvelope.ReferrerStats])):
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
      assertionFailure("Unrecognized (\(type(of: cell)), \(type(of: value))) combo.")
    }
  }
}
