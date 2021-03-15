import Foundation
import KsApi

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

  static func discoveryContext(for sort: DiscoveryParams.Sort) -> KSRAnalytics.TypeContext.DiscoveryContext {
    switch sort {
    case .endingSoon: return .endingSoon
    case .magic: return .magic
    case .newest: return .newest
    case .popular: return .popular
    }
  }
}
