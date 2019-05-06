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
    case availableRewards
    case unavailableRewards
  }

  internal func loadMinimal(project: Project) {
    self.set(values: [project], cellClass: ProjectPamphletMinimalCell.self, inSection: Section.main.rawValue)

    let values = [
      ProjectPamphletSubpage.comments(project.stats.commentsCount as Int?, .first),
      ProjectPamphletSubpage.updates(project.stats.updatesCount as Int?, .last)
    ]

    self.set(
      values: values,
      cellClass: ProjectPamphletSubpageCell.self,
      inSection: Section.subpages.rawValue
    )

    if !featureNativeCheckoutEnabled() {
      self.setRewardTitleArea(project: project)
    }
  }

  internal func load(project: Project, visible: Bool = false) {
    self.clearValues()

    self.set(values: [project], cellClass: ProjectPamphletMainCell.self, inSection: Section.main.rawValue)

    let values: [ProjectPamphletSubpage] = [
      .comments(project.stats.commentsCount as Int?, .first),
      .updates(project.stats.updatesCount as Int?, .last)
    ]

    self.set(
      values: values,
      cellClass: ProjectPamphletSubpageCell.self,
      inSection: Section.subpages.rawValue
    )

    if !featureNativeCheckoutEnabled() {
      self.setRewardTitleArea(project: project)
      self.setRewards(project: project, visible)
    }
  }

  private func featureNativeCheckoutEnabled() -> Bool {
    return AppEnvironment.current.config?.features[Feature.checkout.rawValue] == .some(true)
  }

  private func availableRewards(for project: Project) -> [(Project, Either<Reward, Backing>)] {
    return project.rewards
      .filter { isMainReward(reward: $0, project: project) }
      .filter { $0.remaining == nil || $0.remaining != 0 }
      .sorted()
      .map { (project, Either<Reward, Backing>.left($0)) }
  }

  private func unavailableRewards(for project: Project) -> [(Project, Either<Reward, Backing>)] {
    return project.rewards
      .filter { isMainReward(reward: $0, project: project) }
      .filter { $0.remaining != nil && $0.remaining == 0 }
      .sorted()
      .map { (project, Either<Reward, Backing>.left($0)) }
  }

  private func setRewardTitleArea(project: Project) {
    if project.personalization.isBacking != true, project.state == .live {
      self.set(values: [project], cellClass: PledgeTitleCell.self, inSection: Section.pledgeTitle.rawValue)
      self.set(values: [project], cellClass: NoRewardCell.self, inSection: Section.calloutReward.rawValue)
    } else if let backing = project.personalization.backing {
      self.set(values: [project], cellClass: PledgeTitleCell.self, inSection: Section.pledgeTitle.rawValue)
      self.set(values: [(project, .right(backing))],
               cellClass: DeprecatedRewardCell.self,
               inSection: Section.calloutReward.rawValue)
    }
  }

  private func setRewards(project: Project, _ visible: Bool) {
    let rewardData = project.rewards
      .filter { isMainReward(reward: $0, project: project) }
      .sorted()
      .map { (project, Either<Reward, Backing>.left($0)) }

    if !rewardData.isEmpty {
      if visible {
        self.set(values: [project],
                 cellClass: RewardsTitleCell.self,
                 inSection: Section.rewardsTitle.rawValue)
      }

      self.set(values: availableRewards(for: project),
               cellClass: DeprecatedRewardCell.self,
               inSection: Section.availableRewards.rawValue)
      self.set(values: unavailableRewards(for: project),
               cellClass: DeprecatedRewardCell.self,
               inSection: Section.unavailableRewards.rawValue)
    }
  }

  private func liveStreamSubpages(forLiveStreamEvents liveStreamEvents: [LiveStreamEvent]) ->
    [ProjectPamphletSubpage] {

    guard AppEnvironment.current.config?.features[Feature.liveStreams.rawValue] != .some(false)
      else { return [] }

    return liveStreamEvents
      .sorted(comparator: LiveStreamEvent.canonicalLiveStreamEventComparator(
        now: AppEnvironment.current.dateType.init().date)
      )
    }
  }

  internal func indexPathForMainCell() -> IndexPath {
    return IndexPath(item: 0, section: Section.main.rawValue)
  }

  internal func indexPathIsCommentsSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isComments == true
  }

  internal func indexPathIsUpdatesSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isUpdates == true
  }

  internal func indexPathIsPledgeAnyAmountCell(_ indexPath: IndexPath) -> Bool {
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
    case let (cell as DeprecatedRewardCell, value as (Project, Either<Reward, Backing>)):
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
      fatalError("Unrecognized (\(type(of: cell)), \(type(of: value))) combo.")
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
private func isMainReward(reward: Reward, project: Project) -> Bool {
  // Don't show the no-reward reward
  guard reward.id != 0 else { return false }
  // Don't show the reward the user is backing
  guard .some(reward.id) != project.personalization.backing?.rewardId else { return false }
  // Show all rewards when the project isn't live
  guard project.state == .live else { return true }

  let now = AppEnvironment.current.dateType.init().timeIntervalSince1970
  let startsAt = reward.startsAt ?? 0
  let endsAt = (reward.endsAt == .some(0) ? nil : reward.endsAt) ?? project.dates.deadline

  return startsAt <= now && now <= endsAt
}
