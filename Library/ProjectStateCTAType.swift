import UIKit

public enum ProjectStateCTAType {
  case pledge
  case manage
  case viewBacking
  case viewRewards

  public var buttonTitle: String {
    switch self {
    case .pledge:
      return "Back this project"
    case .manage:
      return "Manage"
    case .viewBacking:
      return "View your pledge"
    case .viewRewards:
      return "View rewards"
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
