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

    // FIXME
//    self.set(values: [project], cellClass: DashboardContextCell.self, section: Section.Context.rawValue)

    // FIXME
//    self.set(values: [project], cellClass: DashboardActionCell.self, section: Section.Action.rawValue)
  }

  internal func load(fundingDateStats stats: [ProjectStatsEnvelope.FundingDateStats], project: Project) {

    // FIXME
//    self.set(
//      values: [(stats, project)],
//      cellClass: DashboardFundingCell.self,
//      inSection: Section.FundingProgress.rawValue
//    )
  }

  internal func load(cumulative: ProjectStatsEnvelope.CumulativeStats,
                                project: Project,
                                referrers: [ProjectStatsEnvelope.ReferrerStats]) {

    // FIXME
//    self.set(values: [(cumulative, project, referrers)], cellClass: DashboardReferrersCell.self,
//             inSection: Section.Referrers.rawValue)
  }

  internal func load(rewardStats: [ProjectStatsEnvelope.RewardStats],
                                 project: Project) {

    // FIXME
//    self.set(values: [(rewardStats: rewardStats, project: project)], cellClass: DashboardRewardsCell.self,
//             inSection: Section.Rewards.rawValue)
  }

  internal func load(videoStats: ProjectStatsEnvelope.VideoStats) {

    // FIXME
//    self.set(values: [videoStats], cellClass: DashboardVideoCell.self, section: Section.Video.rawValue)
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
      assertionFailure("Unrecognized (\(type(of: cell)), \(type(of: value))) combo.")
    }
  }

  internal func didSelectContext(at indexPath: IndexPath) -> Bool {
    return indexPath.section == Section.context.rawValue
  }
}
