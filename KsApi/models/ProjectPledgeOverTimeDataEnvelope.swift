import Foundation
import ReactiveSwift

public struct ProjectPledgeOverTimeDataEnvelope {
  public let rewards: [Reward]
  public let isPledgeOverTimeAllowed: Bool
  public let pledgeOverTimeCollectionPlanChargeExplanation: String?
  public let pledgeOverTimeCollectionPlanChargedAsNPayments: String?
  public let pledgeOverTimeCollectionPlanShortPitch: String?
  public let pledgeOverTimeMinimumExplanation: String?
}

extension ProjectPledgeOverTimeDataEnvelope: Decodable {}
