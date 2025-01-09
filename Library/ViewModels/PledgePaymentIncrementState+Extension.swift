import KsApi
import UIKit

extension PledgePaymentIncrementState {
  // TODO: Add string translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)

  /// Returns the textual description for each `PledgePaymentIncrementState`.
  public var description: String {
    switch self {
    case .collected: return Strings.project_view_pledge_status_collected()
    case .unattempted: return Strings.Scheduled()
    case .errored: return "Errored payment"
    }
  }

  /// Returns the badge background color based on the state.
  public var badgeColor: UIColor {
    switch self {
    case .collected:
      return .ksr_create_100
    case .unattempted:
      return .ksr_support_200
    case .errored:
      return .ksr_celebrate_100
    }
  }

  /// Returns the badge text (foreground) color based on the state.
  public var badgeForegroundColor: UIColor {
    switch self {
    case .collected:
      return .ksr_create_700
    case .unattempted, .errored:
      return .ksr_support_400
    }
  }
}
