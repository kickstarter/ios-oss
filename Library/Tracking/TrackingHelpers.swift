import Foundation

final class TrackingHelpers {
  static func pledgeContext(for viewContext: PledgeViewContext) -> KSRAnalytics.PledgeContext {
    switch viewContext {
    case .pledge:
      return KSRAnalytics.PledgeContext.newPledge
    case .update, .changePaymentMethod:
      return KSRAnalytics.PledgeContext.manageReward
    case .updateReward:
      return KSRAnalytics.PledgeContext.changeReward
    case .fixPaymentMethod:
      return KSRAnalytics.PledgeContext.fixErroredPledge
    }
  }
}
