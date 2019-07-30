import UIKit
import KsApi

public enum ProjectState {
  case nonlive
  case live
}

public enum RewardCellProjectBackingState: Equatable {
  case backedError(activeState: RewardState)
  case nonBacked(live: ProjectState, activeState: RewardState)
  case backed(live: ProjectState, activeState: RewardState)

  static func state(with project: Project, reward: Reward) -> RewardCellProjectBackingState {
    let backing = project.personalization.backing

    let isBacking = userIsBacking(reward: reward, inProject: project)

    guard let projectBacking = backing, isBacking else {
      return project.state == .live
        ? nonBacked(live: .live, activeState: RewardState.state(with: reward, project: project))
        : nonBacked(live: .nonlive, activeState: RewardState.state(with: reward, project: project))
    }

    switch(project.state, projectBacking.status) {
    case(.live, .errored):
      return .backedError(activeState: RewardState.state(with: reward, project: project))
    case(.live, _):
      return .backed(live: .live, activeState: RewardState.state(with: reward, project: project))
    case (_, _):
      return .backed(live: .nonlive, activeState: RewardState.state(with: reward, project: project))
    }
  }

  public enum RewardState {
    case limited
    case timebased
    case both
    case inactive
    case unknown

    static func state(with reward: Reward, project: Project) -> RewardState {
      let remaining = reward.remaining != .some(0)
      let limit = reward.limit
      let now = AppEnvironment.current.dateType.init().timeIntervalSince1970
      let startsAt = reward.startsAt ?? 0
      let endsAt = (reward.endsAt == .some(0) ? nil : reward.endsAt) ?? project.dates.deadline

      if remaining && limit != 0 && startsAt <= now && now <= endsAt {
        return .both
      } else if remaining == false && limit == nil && endsAt <= now || project.state != .live { 
        return .inactive
      } else if remaining && limit != nil {
        return .limited
      } else if startsAt <= now && now <= endsAt {
        return .timebased
      }
      return .unknown // we should never get to this state
    }
  }
}

