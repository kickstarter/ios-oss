import UIKit

public enum PledgeStateCTAType {
  case pledge
  case manage
  case viewBacking
  case viewRewards

  public var buttonBackgroundColor: UIColor {
    switch self {
    case .pledge:
      return .ksr_green_500
    case .manage:
      return .ksr_blue_500
    case .viewBacking, .viewRewards:
      return .ksr_soft_black
    }
  }

  public var buttonTitle: String {
    switch self {
    case .pledge:
      return Strings.Back_this_project()
    case .manage:
      return Strings.Manage()
    case .viewBacking:
      return Strings.View_your_pledge()
    case .viewRewards:
      return Strings.View_rewards()
    }
  }

  public var stackViewAndSpacerAreHidden: Bool {
    switch self {
    case .pledge, .viewBacking, .viewRewards:
      return true
    case .manage:
      return false
    }
  }
}
