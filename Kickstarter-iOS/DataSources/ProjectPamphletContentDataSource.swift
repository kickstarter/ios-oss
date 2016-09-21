import KsApi
import Library

internal final class ProjectPamphletContentDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case main
    case subpages
    case pledgeTitle
    case calloutReward
    case rewardsTitle
    case rewards
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
    } else if let reward = backingReward(fromProject: project)
      where project.personalization.isBacking == true {

      self.set(values: [project], cellClass: PledgeTitleCell.self, inSection: Section.pledgeTitle.rawValue)
      self.set(values: [(project, reward)],
               cellClass: RewardCell.self,
               inSection: Section.calloutReward.rawValue)
    }

    let rewards = project.rewards
      .filter { $0.id != 0 && $0.id != project.personalization.backing?.rewardId }
      .sort()
      .map { (project, $0) }

    if !rewards.isEmpty {
      self.set(values: [project], cellClass: RewardsTitleCell.self, inSection: Section.rewardsTitle.rawValue)
      self.set(values: rewards, cellClass: RewardCell.self, inSection: Section.rewards.rawValue)
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
    case let (cell as RewardCell, value as (Project, Reward)):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletMainCell, value as Project):
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
  guard let reward = project.personalization.backing?.reward else {
    return project.rewards
      .filter {
        $0.id == project.personalization.backing?.rewardId
          || $0.id == project.personalization.backing?.reward?.id
      }
      .first
  }

  return reward
}
