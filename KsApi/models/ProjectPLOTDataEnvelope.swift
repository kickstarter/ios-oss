import Foundation
import ReactiveSwift

public struct ProjectPLOTDataEnvelope {
  public let isPledgeOverTimeAllowed: Bool
  public let pledgeOverTimeCollectionPlanChargeExplanation: String?
  public let pledgeOverTimeCollectionPlanChargedAsNPayments: String?
  public let pledgeOverTimeCollectionPlanShortPitch: String?
  public let pledgeOverTimeMinimumExplanation: String?
}

// MARK: - GraphQL Adapters

extension ProjectPLOTDataEnvelope {
  static func envelopeProducer(
    from data: GraphAPI.FetchProjectPlotDataQuery
      .Data
  ) -> SignalProducer<ProjectPLOTDataEnvelope, ErrorEnvelope> {
    guard let dataUnwrapped = data.project else {
      return SignalProducer(error: .couldNotParseJSON)
    }

    let envelope = ProjectPLOTDataEnvelope(
      isPledgeOverTimeAllowed: dataUnwrapped.isPledgeOverTimeAllowed,
      pledgeOverTimeCollectionPlanChargeExplanation: dataUnwrapped
        .pledgeOverTimeCollectionPlanChargeExplanation,
      pledgeOverTimeCollectionPlanChargedAsNPayments: dataUnwrapped
        .pledgeOverTimeCollectionPlanChargedAsNPayments,
      pledgeOverTimeCollectionPlanShortPitch: dataUnwrapped.pledgeOverTimeCollectionPlanShortPitch,
      pledgeOverTimeMinimumExplanation: dataUnwrapped.pledgeOverTimeMinimumExplanation
    )

    return SignalProducer(value: envelope)
  }
}

extension ProjectPLOTDataEnvelope: Decodable {}
