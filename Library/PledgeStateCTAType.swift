import UIKit

public enum PledgeStateCTAType {
  case pledge
  case manage
  case viewBacking
  case viewRewards

  public var buttonTitle: String {
    switch self {
    case .pledge:
      return Strings.Back_this_project()
    case .manage:
      return "Manage"
    case .viewBacking:
      return Strings.View_your_pledge()
    case .viewRewards:
      return "View_rewards"
    }
  }

  public var buttonBackgroundColor: UIColor {
    switch self {
    case .pledge:
      return .ksr_green_500
    case .manage:
      return .ksr_blue
    case .viewBacking, .viewRewards:
      return .ksr_soft_black
    }
  }

  public var stackViewIsHidden: Bool {
    switch self {
    case .pledge, .viewBacking, .viewRewards:
      return true
    case .manage:
      return false
    }
  }
}
