import UIKit

public enum PledgeStateCTAType {
  case fix
  case pledge
  case manage
  case viewBacking
  case viewRewards

  public var buttonTitle: String {
    switch self {
    case .fix:
      return Strings.Fix()
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

  public var buttonStyle: ButtonStyleType {
    switch self {
    case .fix:
      return .apricot
    case .pledge:
      return .green
    case .manage:
      return .blue
    case .viewBacking, .viewRewards:
      return .black
    }
  }

  public var stackViewIsHidden: Bool {
    switch self {
    case .pledge, .viewBacking, .viewRewards:
      return true
    case .fix, .manage:
      return false
    }
  }

  public var titleLabel: String? {
    switch self {
    case .fix:
      return Strings.Check_your_payment_details()
    case .manage:
      return Strings.Youre_a_backer()
    default:
      return nil
    }
  }

  public var subtitleLabel: String? {
    switch self {
    case .fix:
      return Strings.We_couldnt_process_your_pledge()
    default:
      return nil
    }
  }

  public var stackViewAndSpacerAreHidden: Bool {
    switch self {
    case .pledge, .viewBacking, .viewRewards:
      return true
    case .fix, .manage:
      return false
    }
  }
}
