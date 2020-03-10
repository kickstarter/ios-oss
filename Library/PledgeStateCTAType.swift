import UIKit

public enum PledgeStateCTAType {
  case fix
  case pledge
  case manage
  case viewBacking
  case viewRewards
  case viewYourRewards
  // Experimental
  case seeTheRewards
  case viewTheRewards

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
    case .seeTheRewards:
      return Strings.See_the_rewards()
    case .viewTheRewards:
      return Strings.View_the_rewards()
    }
  }

  public var buttonStyle: ButtonStyleType {
    switch self {
    case .fix:
      return .red
    case .pledge, .seeTheRewards, .viewTheRewards:
      return .green
    case .manage:
      return .blue
    case .viewBacking, .viewRewards, .viewYourRewards:
      return .black
    }
  }

  public var stackViewIsHidden: Bool {
    switch self {
    case .pledge, .seeTheRewards, .viewBacking, .viewRewards, .viewYourRewards, .viewTheRewards:
      return true
    case .fix, .manage:
      return false
    }
  }

  public var titleLabel: String? {
    switch self {
    case .fix:
      return Strings.Payment_failure()
    case .manage:
      return Strings.Youre_a_backer()
    default:
      return nil
    }
  }

  public var subtitleLabel: String? {
    switch self {
    case .fix:
      return Strings.We_cant_process_your_pledge()
    default:
      return nil
    }
  }

  public var stackViewAndSpacerAreHidden: Bool {
    switch self {
    case .pledge, .seeTheRewards, .viewBacking, .viewRewards, .viewYourRewards, .viewTheRewards:
      return true
    case .fix, .manage:
      return false
    }
  }
}
