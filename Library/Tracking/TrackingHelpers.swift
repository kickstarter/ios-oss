import Foundation

final class TrackingHelpers {
  static func pledgeContext(for viewContext: PledgeViewContext) -> KSRAnalytics.TypeContext.PledgeContext {
    switch viewContext {
    case .pledge:
      return .newPledge
    case .update, .changePaymentMethod:
      return .managePledge
    case .updateReward:
      return .changeReward
    case .fixPaymentMethod:
      return .fixErroredPledge
    }
  }
}
