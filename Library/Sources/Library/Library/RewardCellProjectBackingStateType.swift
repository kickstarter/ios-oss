import KsApi
import UIKit

public enum RewardCellProjectBackingStateType: Equatable {
  public enum ProjectState {
    case nonLive
    case live
    case inPostCampaignPledgingPhase
  }

  case nonBacked(live: ProjectState)
  case backed(live: ProjectState)

  static func state(with project: Project) -> RewardCellProjectBackingStateType {
    guard project.personalization.backing != nil else {
      if project.isInPostCampaignPledgingPhase {
        return .nonBacked(live: .inPostCampaignPledgingPhase)
      }

      return .nonBacked(live: project.state == .live ? .live : .nonLive)
    }

    switch project.state {
    case .live:
      return .backed(live: .live)
    default:
      return .backed(live: .nonLive)
    }
  }

  var canCreateNewPledge: Bool {
    switch self {
    case .nonBacked(live: .live):
      return true
    case .nonBacked(live: .inPostCampaignPledgingPhase):
      return true
    case .nonBacked(live: .nonLive):
      return false

    case .backed:
      return false
    }
  }
}
