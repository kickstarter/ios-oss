import UIKit

public enum RewardStateType {
  case fix
  case pledge
  case manage
  case viewBacking

  public var buttonBackgroundColor: UIColor {
    switch self {
    case .fix:
      return .ksr_apricot_600
    case .pledge:
      return .ksr_green_500
    case .manage:
      return .ksr_blue_500
    case .viewBacking:
      return .ksr_soft_black
    }
  }

  public var buttonTitle: String {
    switch self {
    case .fix:
      return "Fix your payment method"
    case .pledge:
      return Strings.Back_this_project()
    case .manage:
      return Strings.Manage()
    case .viewBacking:
      return Strings.View_your_pledge()
    }
  }

  public var showTimeLeftPill: Bool? {
    switch self {
    case .fix, .pledge, .manage:
      return true
    case .viewBacking:
      return false
    }
  }

  public var showLimitedRewardPill: Bool? {
    switch self {
    case .fix, .pledge, .manage:
      return true
    case .viewBacking:
      return false
    }
  }

  var showStateIconImage: Bool? {
    switch self {
    case .fix, .manage, .viewBacking:
      return true
    case .pledge:
      return false
    }
  }

  var stateIconImageName: String? {
    switch self {
    case .fix:
      return "fix--reward"
    default:
      return "checkmark-reward"
    }
  }

  var stateIconImageTintColor: UIColor {
    switch self {
    case .fix:
      return .ksr_apricot_600
    case .pledge:
      return .ksr_green_500
    case .manage:
      return .ksr_blue_500
    case .viewBacking:
      return .ksr_soft_black
    }
  }
}
