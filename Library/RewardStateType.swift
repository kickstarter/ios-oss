import UIKit

public enum RewardStateType {
  case fix // Backed, Live, Backing.error
  case pledge // Not Backed, Live
  case manage // Backed, Live
  case viewBacking // Backed, NonLive

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
      return Strings.Fix_your_payment_method()
    case .pledge:
      return Strings.Back_this_project()
    case .manage:
      return Strings.Manage_your_pledge()
    case .viewBacking:
      return Strings.View_your_pledge()
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

public enum ActiveStateType { // We would check for Rewards.remaining and Rewards.endsAt to determine this
  case limitedReward
  case timebasedReward
  case both
  case inactive

  public var buttonDisabled: Bool? {
    switch self {
    case .inactive:
      return true
    case .both, .limitedReward, .timebasedReward:
      return false
    }
  }

  public var showTimeLeftPill: Bool? {
    switch self {
    case .timebasedReward, .both:
      return true
    case .inactive:
      return false
    default:
      return nil
    }
  }

  public var showLimitedRewardPill: Bool? {
    switch self {
    case .limitedReward, .both:
      return true
    case .inactive:
      return false
    default:
      return nil
    }
  }
}
