import KsApi
import Library
import LiveStream
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

  internal func loadMinimal(project: Project) {
    self.set(values: [project], cellClass: ProjectPamphletMinimalCell.self, inSection: Section.main.rawValue)
  }

  internal func load(project: Project, liveStreamEvents: [LiveStreamEvent]) {
    self.clearValues()

    self.set(values: [project], cellClass: ProjectPamphletMainCell.self, inSection: Section.main.rawValue)

    let liveStreamSubpages = self.liveStreamSubpages(forLiveStreamEvents: liveStreamEvents)

    let values = liveStreamSubpages + [
      .comments(project.stats.commentsCount ?? 0, liveStreamSubpages.isEmpty ? .first : .middle),
      .updates(project.stats.updatesCount ?? 0, .last)
      ]

    self.set(
      values: values,
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
      .sorted()
      .map { (project, Either<Reward, Backing>.left($0)) }

    if !rewardData.isEmpty {
      self.set(values: [project], cellClass: RewardsTitleCell.self, inSection: Section.rewardsTitle.rawValue)
      self.set(values: rewardData, cellClass: RewardCell.self, inSection: Section.rewards.rawValue)
    }
  }

  private func liveStreamSubpages(forLiveStreamEvents liveStreamEvents: [LiveStreamEvent]) ->
    [ProjectPamphletSubpage] {

    guard AppEnvironment.current.config?.features["ios_live_streams"] != .some(false) else { return [] }

    let now = AppEnvironment.current.dateType.init().date

    // Compares two live streams, putting live ones first.
    let currentlyLiveStreamsFirstComparator = Prelude.Comparator<LiveStreamEvent> { lhs, rhs in
      switch (lhs.liveNow, rhs.liveNow) {
      case (true, false):                 return .lt
      case (false, true):                 return .gt
      case (true, true), (false, false):  return .eq
      }
    }

    // Compares two live streams, putting the future ones first.
    let futureLiveStreamsFirstComparator = Prelude.Comparator<LiveStreamEvent> { lhs, rhs in
      lhs.startDate > now && rhs.startDate > now
        || lhs.startDate < now && rhs.startDate < now
        ? .eq : lhs.startDate < rhs.startDate ? .gt
        : .lt
    }

    // Compares two live streams, putting soon-to-be-live first and way-back past last.
    let startDateComparator = Prelude.Comparator<LiveStreamEvent> { lhs, rhs in
      lhs.startDate > now
        ? (lhs.startDate == rhs.startDate
          ? .eq : lhs.startDate < rhs.startDate ? .lt: .gt)
        : (lhs.startDate == rhs.startDate
          ? .eq : lhs.startDate < rhs.startDate ? .gt: .lt)
    }

    // Sort by:
    //   * live streams first
    //   * then future streams first and past streams last
    //   * future streams sorted by start date asc, past streams sorted by start date desc
    let comparator = currentlyLiveStreamsFirstComparator
      <> futureLiveStreamsFirstComparator
      <> startDateComparator

    return liveStreamEvents
      .sorted(comparator: comparator)
      .enumerated()
      .map { idx, liveStreamEvent in
        ProjectPamphletSubpage.liveStream(liveStreamEvent: liveStreamEvent, idx == 0 ? .first : .middle)
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

  internal func indexPathIsLiveStreamSubpage(indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isLiveStream == true
  }

  internal func liveStream(forIndexPath indexPath: IndexPath) -> LiveStreamEvent? {
    return (self[indexPath] as? ProjectPamphletSubpage)?.liveStreamEvent
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
