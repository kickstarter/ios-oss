import KsApi
import UIKit

public enum RewardCellProjectBackingStateType: Equatable {
  public enum ProjectState {
    case nonLive
    case live
  }

  case backedError
  case nonBacked(live: ProjectState)
  case backed(live: ProjectState)

  static func state(with project: Project) -> RewardCellProjectBackingStateType {
    guard let backing = project.personalization.backing else {
      return .nonBacked(live: project.state == .live ? .live : .nonLive)
    }

    // NB: Add error case back once correctly returned
    switch (project.state, backing.status) {
    case(.live, _):
      return .backed(live: .live)
    case (_, _):
      return .backed(live: .nonLive)
    }
  }
}
