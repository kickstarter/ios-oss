import KsApi
import UIKit

extension PledgePaymentIncrementState {
  // TODO: Add string translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)

  /// Returns the textual description for each `PledgePaymentIncrementState`.
  public var description: String {
    switch self {
    case .collected: return "Collected"
    case .unattempted: return "Scheduled"
    case .unknown: return "Unknown"
    case .cancelled: return "Cancelled"
    case .errored: return "Errored payment"
    }
  }

  /// Returns the badge background color based on the state.
  public var badgeColor: UIColor {
    switch self {
    case .collected:
      return .ksr_create_100
    case .unattempted, .unknown:
      return .ksr_support_200
    case .cancelled, .errored:
      return .ksr_celebrate_100
    }
  }

  /// Returns the badge text (foreground) color based on the state.
  public var badgeForegroundColor: UIColor {
    switch self {
    case .collected:
      return .ksr_create_700
    case .unattempted, .unknown, .cancelled, .errored:
      return .ksr_support_400
    }
  }
}
