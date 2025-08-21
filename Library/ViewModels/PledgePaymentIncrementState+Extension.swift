import KDS
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
    case .refunded: return Strings.Refunded()
    }
  }

  /// Returns the badge background color based on the state.
  public var badgeStyle: BadgeStyle {
    switch self {
    case .collected:
      // TODO: Add support to apply alpha to background color for light mode only. See: MBL-2650
      return .custom(
        foregroundColor: Colors.PLOT.Badge.Text.collected.uiColor(),
        backgroundColor: Colors.PLOT.Badge.Background.collected.uiColor()
      )
    case .unattempted:
      return .custom(
        foregroundColor: Colors.PLOT.Badge.Text.scheduled.uiColor(),
        backgroundColor: Colors.PLOT.Badge.Background.scheduled.uiColor()
      )
    case .cancelled:
      return .custom(
        foregroundColor: Colors.PLOT.Badge.Text.canceled.uiColor(),
        backgroundColor: Colors.PLOT.Badge.Background.canceled.uiColor()
      )
    case .errored:
      return .custom(
        foregroundColor: Colors.PLOT.Badge.Text.errored.uiColor(),
        backgroundColor: Colors.PLOT.Badge.Background.errored.uiColor()
      )
    case .refunded:
      return .custom(
        foregroundColor: Colors.PLOT.Badge.Text.refunded.uiColor(),
        backgroundColor: Colors.PLOT.Badge.Background.refunded.uiColor()
      )
    }
  }
}
