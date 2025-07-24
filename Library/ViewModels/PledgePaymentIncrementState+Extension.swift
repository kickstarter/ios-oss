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
    // TODO: [MBL-2644] implement translated strings.
    case .refunded: return "FPO: Refunded"
    }
  }

  /// Returns the badge background color based on the state.
  public var badgeStyle: BadgeStyle {
    switch self {
    case .collected:
      return .success
    // TODO: setup the correct color of `refunded` on [MBL-2643]
    case .unattempted, .cancelled, .refunded:
      return .custom(
        foregroundColor: LegacyColors.ksr_support_400.uiColor(),
        backgroundColor: LegacyColors.ksr_support_200.uiColor()
      )
    case .errored:
      return .error
    }
  }
}
