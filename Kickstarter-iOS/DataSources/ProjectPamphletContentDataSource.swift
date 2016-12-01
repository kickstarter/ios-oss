import KsApi
import Library
import Prelude

internal final class ProjectPamphletContentDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case main
    case subpages
    case pledgeTitle
    case calloutReward
    case rewardsTitle
    case rewards
  }

  internal func loadMinimal(project project: Project) {
    self.set(values: [project], cellClass: ProjectPamphletMinimalCell.self, inSection: Section.main.rawValue)
  }

  internal func load(project project: Project) {
    self.clearValues()

    self.set(values: [project], cellClass: ProjectPamphletMainCell.self, inSection: Section.main.rawValue)

    self.set(
      values: [
        .comments(project.stats.commentsCount ?? 0, true),
        .updates(project.stats.updatesCount ?? 0, false)
      ],
      cellClass: ProjectPamphletSubpageCell.self,
      inSection: Section.subpages.rawValue
    )

    if project.personalization.isBacking != true && project.state == .live {
      self.set(values: [project], cellClass: PledgeTitleCell.self, inSection: Section.pledgeTitle.rawValue)
      self.set(values: [project], cellClass: NoRewardCell.self, inSection: Section.calloutReward.rawValue)
    } else if let backing = project.personalization.backing {

      self.set(values: [project], cellClass: PledgeTitleCell.self, inSection: Section.pledgeTitle.rawValue)
      self.set(values: [(project, .right(backing))],
               cellClass: RewardCell.self,
               inSection: Section.calloutReward.rawValue)
    }

    let rewardData = project.rewards
      .filter { isMainReward(reward: $0, project: project) }
      .sort()
      .map { (project, Either<Reward, Backing>.left($0)) }

    if !rewardData.isEmpty {
      self.set(values: [project], cellClass: RewardsTitleCell.self, inSection: Section.rewardsTitle.rawValue)
      self.set(values: rewardData, cellClass: RewardCell.self, inSection: Section.rewards.rawValue)
    }
  }

  internal func indexPathForMainCell() -> NSIndexPath {
    return NSIndexPath(forItem: 0, inSection: Section.main.rawValue)
  }

  internal func indexPathIsCommentsSubpage(indexPath: NSIndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isComments == true
  }

  internal func indexPathIsUpdatesSubpage(indexPath: NSIndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isUpdates == true
  }

  internal func indexPathIsPledgeAnyAmountCell(indexPath: NSIndexPath) -> Bool {
    guard let project = self[indexPath] as? Project else {
      return false
    }

    return project.personalization.isBacking != true
      && project.state == .live
      && indexPath.item == 0
      && indexPath.section == Section.calloutReward.rawValue
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as RewardCell, value as (Project, Either<Reward, Backing>)):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletMainCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletMinimalCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletSubpageCell, value as ProjectPamphletSubpage):
      cell.configureWith(value: value)
    case let (cell as PledgeTitleCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as NoRewardCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as RewardsTitleCell, value as Project):
      cell.configureWith(value: value)
    default:
      fatalError("Unrecognized (\(cell.dynamicType), \(value.dynamicType)) combo.")
    }
  }
}

private func backingReward(fromProject project: Project) -> Reward? {

  guard let backing = project.personalization.backing else {
    return nil
  }

  return project.rewards
    .filter { $0.id == backing.rewardId || $0.id == backing.reward?.id }
    .first
    .coalesceWith(.noReward)
}

// Determines if a reward belongs in the main list of rewards.
private func isMainReward(reward reward: Reward, project: Project) -> Bool {
  // Don't show the no-reward reward
  guard reward.id != 0 else { return false }
  // Don't show the reward the user is backing
  guard .Some(reward.id) != project.personalization.backing?.rewardId else { return false }
  // Show all rewards when the project isn't live
  guard project.state != .live else { return true }

  let now = AppEnvironment.current.dateType.init().timeIntervalSince1970
  let startsAt = reward.startsAt ?? 0
  let endsAt = reward.endsAt ?? now

  return startsAt <= now && now <= endsAt
}
