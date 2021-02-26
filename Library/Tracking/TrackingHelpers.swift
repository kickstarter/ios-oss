import Foundation

final class TrackingHelpers {
  static func pledgeContext(for viewContext: PledgeViewContext) -> KSRAnalytics.TypeContext.PledgeContext {
    switch viewContext {
    case .pledge:
      return .newPledge
    case .update, .updateReward, .changePaymentMethod:
      return .managePledge
    case .fixPaymentMethod:
      return .fixErroredPledge
    }
  }
}
