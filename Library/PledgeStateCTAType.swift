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
      return "Fix"
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

  public var buttonBackgroundColor: UIColor {
    switch self {
    case .fix:
      return .ksr_apricot_600
    case .pledge:
      return .ksr_green_500
    case .manage:
      return .ksr_blue
    case .viewBacking, .viewRewards:
      return .ksr_soft_black
    }
  }

  public var buttonTitleTextColor: UIColor {
    switch self {
    case .pledge, .manage, .viewBacking, .viewRewards:
      return .white
    case .fix:
     return .ksr_soft_black
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

  public var subtitleLabel: String? {
    switch self {
    case .fix:
      return "Check your payment details"
    case .manage:
      return Strings.Youre_a_backer()
    default:
      return nil
    }
  }

  public var titleLabel: String? {
    switch self {
    case .fix:
      return "We couldn't process your pledge."
    default:
      return nil
    }
  }
}
