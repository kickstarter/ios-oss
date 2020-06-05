import Foundation

final class TrackingHelpers {
  static func pledgeContext(for viewContext: PledgeViewContext) -> Koala.PledgeContext {
    switch viewContext {
    case .pledge:
      return Koala.PledgeContext.newPledge
    case .update, .changePaymentMethod:
      return Koala.PledgeContext.manageReward
    case .updateReward:
      return Koala.PledgeContext.changeReward
    case .fixPaymentMethod:
      return Koala.PledgeContext.fixErroredPledge
    }
  }
}
