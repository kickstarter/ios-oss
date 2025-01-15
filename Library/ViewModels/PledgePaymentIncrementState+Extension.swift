import KsApi
import UIKit

extension PledgePaymentIncrementState {
  /// Returns the textual description for each `PledgePaymentIncrementState`.
  public var description: String {
    switch self {
    case .collected: return Strings.project_view_pledge_status_collected()
    case .unattempted: return Strings.Scheduled()
    case .errored: return Strings.Errored_payment()
    case .cancelled: return Strings.profile_projects_status_canceled()
    }
  }

  /// Returns the badge background color based on the state.
  public var badgeColor: UIColor {
    switch self {
    case .collected:
      return .ksr_create_100
    case .unattempted, .cancelled:
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
    case .unattempted, .errored, .cancelled:
      return .ksr_support_400
    }
  }
}
