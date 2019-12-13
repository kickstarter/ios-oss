import UIKit

public enum PledgeStateCTAType {
  case fix
  case pledge
  case manage
  case viewBacking
  case viewRewards
  case viewYourRewards

  public var buttonTitle: String {
    switch self {
    case .fix:
      return Strings.Manage()
    case .pledge:
      return Strings.Back_this_project()
    case .manage:
      return Strings.Manage()
    case .viewBacking:
      return Strings.View_your_pledge()
    case .viewRewards:
      return Strings.View_rewards()
    case .viewYourRewards:
      return Strings.View_your_rewards()
    }
  }

  public var buttonStyle: ButtonStyleType {
    switch self {
    case .fix:
      return .red
    case .pledge:
      return .green
    case .manage:
      return .blue
    case .viewBacking, .viewRewards, .viewYourRewards:
      return .black
    }
  }

  public var stackViewIsHidden: Bool {
    switch self {
    case .pledge, .viewBacking, .viewRewards, .viewYourRewards:
      return true
    case .fix, .manage:
      return false
    }
  }

  public var titleLabel: String? {
    switch self {
    case .fix:
      return localizedString(
        key: "Payment_failure",
        defaultValue: "Payment failure",
        count: nil,
        substitutions: [:]
      )
    case .manage:
      return Strings.Youre_a_backer()
    default:
      return nil
    }
  }

  public var subtitleLabel: String? {
    switch self {
    case .fix:
      return localizedString(
        key: "We_cant_process_your_pledge",
        defaultValue: "We can't process your pledge.",
        count: nil,
        substitutions: [:]
      )
    default:
      return nil
    }
  }

  public var stackViewAndSpacerAreHidden: Bool {
    switch self {
    case .pledge, .viewBacking, .viewRewards, .viewYourRewards:
      return true
    case .fix, .manage:
      return false
    }
  }
}
