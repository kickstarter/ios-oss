
import UIKit

public struct RewardCardConfiguration {
  public let buttonBackgroundColor: UIColor
  public let buttonTitle: String
  public let showStateIconImage: Bool
  public let stateIconImageName: String?
  public let stateIconImageTintColor: UIColor

  public let buttonDisabled: Bool
  public let showTimeLeftPill: Bool
  public let showLimitedRewardPill: Bool
}

public enum RewardState {
  case backedError(activeState: LimitedRewardState) // Backed, Live, Backing.error
  case nonBacked(live: Bool, activeState: LimitedRewardState) // Not Backed, Live
  case backed(live: Bool, activeState: LimitedRewardState) // Backed, Live
  //  case backedNonLive // Backed, NonLive // Active state not shown here

  public var configuration: RewardCardConfiguration {
    switch self {
    case .backedError(.both):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_apricot_600,
        buttonTitle: Strings.Fix_your_payment_method(),
        showStateIconImage: true,
        stateIconImageName: "fix--reward",
        stateIconImageTintColor: .ksr_apricot_600,
        buttonDisabled: false,
        showTimeLeftPill: true,
        showLimitedRewardPill: true
      )
    case .backedError(.limitedReward):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_apricot_600,
        buttonTitle: Strings.Fix_your_payment_method(),
        showStateIconImage: true,
        stateIconImageName: "fix--reward",
        stateIconImageTintColor: .ksr_apricot_600,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: true
      )
    case .backedError(.timebasedReward):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_apricot_600,
        buttonTitle: Strings.Fix_your_payment_method(),
        showStateIconImage: true,
        stateIconImageName: "fix--reward",
        stateIconImageTintColor: .ksr_apricot_600,
        buttonDisabled: false,
        showTimeLeftPill: true,
        showLimitedRewardPill: false
      )
    case .backedError(.inactive):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_apricot_600,
        buttonTitle: Strings.Fix_your_payment_method(),
        showStateIconImage: true,
        stateIconImageName: "fix--reward",
        stateIconImageTintColor: .ksr_apricot_600,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: false
      )
    case .nonBacked(true, .both):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_green_500,
        buttonTitle: Strings.Back_this_project(),
        showStateIconImage: false,
        stateIconImageName: nil,
        stateIconImageTintColor: .ksr_green_500,
        buttonDisabled: false,
        showTimeLeftPill: true,
        showLimitedRewardPill: true
      )
    case .nonBacked(true, .limitedReward):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_green_500,
        buttonTitle: Strings.Back_this_project(),
        showStateIconImage: false,
        stateIconImageName: nil,
        stateIconImageTintColor: .ksr_green_500,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: true
      )
    case .nonBacked(true, .timebasedReward):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_green_500,
        buttonTitle: Strings.Back_this_project(),
        showStateIconImage: false,
        stateIconImageName: nil,
        stateIconImageTintColor: .ksr_green_500,
        buttonDisabled: false,
        showTimeLeftPill: true,
        showLimitedRewardPill: false
      )
    case .nonBacked(true, .inactive):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_green_500,
        buttonTitle: Strings.No_longer_available(),
        showStateIconImage: false,
        stateIconImageName: nil,
        stateIconImageTintColor: .ksr_green_500,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: false
      )
    case .backed(true, .inactive):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_blue_500,
        buttonTitle: Strings.Manage_your_pledge(),
        showStateIconImage: true,
        stateIconImageName: "checkmark-reward",
        stateIconImageTintColor: .ksr_blue_500,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: false
      )
    case .backed(true, .both):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_blue_500,
        buttonTitle: Strings.Manage_your_pledge(),
        showStateIconImage: true,
        stateIconImageName: "checkmark-reward",
        stateIconImageTintColor: .ksr_blue_500,
        buttonDisabled: false,
        showTimeLeftPill: true,
        showLimitedRewardPill: true
      )
    case .backed(true, .limitedReward):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_blue_500,
        buttonTitle: Strings.Manage_your_pledge(),
        showStateIconImage: true,
        stateIconImageName: "checkmark-reward",
        stateIconImageTintColor: .ksr_blue_500,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: true
      )
    case .backed(true, .timebasedReward):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_blue_500,
        buttonTitle: Strings.Manage_your_pledge(),
        showStateIconImage: true,
        stateIconImageName: "checkmark-reward",
        stateIconImageTintColor: .ksr_blue_500,
        buttonDisabled: false,
        showTimeLeftPill: true,
        showLimitedRewardPill: false
      )
    case .backed(false, _):
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_soft_black,
        buttonTitle: Strings.View_your_pledge(),
        showStateIconImage: true,
        stateIconImageName: "checkmark-reward",
        stateIconImageTintColor: .ksr_soft_black,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: false
      )
    case .nonBacked(false, _): // No Button
      return RewardCardConfiguration(
        buttonBackgroundColor: .ksr_soft_black,
        buttonTitle: Strings.View_your_pledge(),
        showStateIconImage: true,
        stateIconImageName: "checkmark-reward",
        stateIconImageTintColor: .ksr_soft_black,
        buttonDisabled: false,
        showTimeLeftPill: false,
        showLimitedRewardPill: false
      )
    }
  }
}

public enum RewardStateType {
  case backedLiveError // Backed, Live, Backing.error
  case nonBackedLive // Not Backed, Live
  case backedLive // Backed, Live
  case backedNonLive // Backed, NonLive // Active state not shown here

  public var buttonBackgroundColor: UIColor {
    switch self {
    case .backedLiveError:
      return .ksr_apricot_600
    case .nonBackedLive:
      return .ksr_green_500
    case .backedLive:
      return .ksr_blue_500
    case .backedNonLive:
      return .ksr_soft_black
    }
  }

  public var buttonTitle: String {
    switch self {
    case .backedLiveError:
      return Strings.Fix_your_payment_method()
    case .nonBackedLive:
      return Strings.Back_this_project()
    case .backedLive:
      return Strings.Manage_your_pledge()
    case .backedNonLive:
      return Strings.View_your_pledge()
    }
  }

  var showStateIconImage: Bool? {
    switch self {
    case .backedLiveError, .backedLive, .backedNonLive:
      return true
    case .nonBackedLive:
      return false
    }
  }

  var stateIconImageName: String? {
    switch self {
    case .backedLiveError:
      return "fix--reward"
    default:
      return "checkmark-reward"
    }
  }

  var stateIconImageTintColor: UIColor {
    switch self {
    case .backedLiveError:
      return .ksr_apricot_600
    case .nonBackedLive:
      return .ksr_green_500
    case .backedLive:
      return .ksr_blue_500
    case .backedNonLive:
      return .ksr_soft_black
    }
  }
}

public enum LimitedRewardState { // We would check for Rewards.remaining and Rewards.endsAt to determine this
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
