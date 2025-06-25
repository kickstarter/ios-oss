import Foundation
import ReactiveSwift

public struct ProjectPledgeOverTimeDataEnvelope {
  public let isPledgeOverTimeAllowed: Bool
  public let pledgeOverTimeCollectionPlanChargeExplanation: String
  public let pledgeOverTimeCollectionPlanChargedAsNPayments: String
  public let pledgeOverTimeCollectionPlanShortPitch: String
  public let pledgeOverTimeMinimumExplanation: String
}

// MARK: - GraphQL Adapters

extension ProjectPledgeOverTimeDataEnvelope {
  static func envelopeProducer(
    from data: GraphAPI.FetchProjectPledgeOverTimeDataQuery
      .Data
  ) -> SignalProducer<ProjectPledgeOverTimeDataEnvelope, ErrorEnvelope> {
    guard let project = data.project else {
      return SignalProducer(error: .couldNotParseJSON)
    }

    let envelope = ProjectPledgeOverTimeDataEnvelope(
      isPledgeOverTimeAllowed: project.isPledgeOverTimeAllowed,
      pledgeOverTimeCollectionPlanChargeExplanation: project
        .pledgeOverTimeCollectionPlanChargeExplanation ?? "",
      pledgeOverTimeCollectionPlanChargedAsNPayments: project
        .pledgeOverTimeCollectionPlanChargedAsNPayments ?? "",
      pledgeOverTimeCollectionPlanShortPitch: project.pledgeOverTimeCollectionPlanShortPitch ?? "",
      pledgeOverTimeMinimumExplanation: project.pledgeOverTimeMinimumExplanation ?? ""
    )

    return SignalProducer(value: envelope)
  }
}

extension ProjectPledgeOverTimeDataEnvelope: Decodable {}
