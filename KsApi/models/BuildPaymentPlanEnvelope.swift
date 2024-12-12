import Foundation
import ReactiveSwift

public struct BuildPaymentPlanEnvelope: Decodable {
  public var projectIsPledgeOverTimeAllowed: Bool
  public var amountIsPledgeOverTimeEligible: Bool
  public var paymentIncrements: [PaymentIncrements]
}

public struct PaymentIncrements: Decodable {
  public var id: String?
  public var amount: Amount
  public var paymentIncrementableId: String?
  public var paymentIncrementableType: String?
  public var scheduledCollection: String
  public var state: String
  public var stateReason: String?

  public struct Amount: Decodable {
    public var amount: String?
    public var currency: GraphAPI.CurrencyCode.RawValue?
  }
}

extension BuildPaymentPlanEnvelope {
  static func envelopeProducer(from data: GraphAPI.BuildPaymentPlanQuery.Data)
    -> SignalProducer<BuildPaymentPlanEnvelope, ErrorEnvelope> {
    guard let envelope = BuildPaymentPlanEnvelope.buildPaymentPlanEnvelope(from: data) else {
      return SignalProducer(error: .couldNotParseJSON)
    }
    return SignalProducer(value: envelope)
  }

  /**
   Returns a minimal `BuildPaymentPlanEnvelope` from a `GraphAPI.BuildPaymentPlanQuery.Data`
   */
  static func buildPaymentPlanEnvelope(
    from data: GraphAPI.BuildPaymentPlanQuery
      .Data
  ) -> BuildPaymentPlanEnvelope? {
    guard let projectIsPledgeOverTimeAllowed = data.project?.paymentPlan?.projectIsPledgeOverTimeAllowed,
          let amountIsPledgeOverTimeEligible = data.project?.paymentPlan?.amountIsPledgeOverTimeEligible,
          let graphAPIPaymentIncrements = data.project?.paymentPlan?.paymentIncrements,
          let id = data.project?.paymentPlan?.paymentIncrements
    else {
      return nil
    }

    let paymentIncrements = graphAPIPaymentIncrements.map {
      let amount = PaymentIncrements.Amount(
        amount: $0.amount.amount,
        currency: $0.amount.currency?.rawValue
      )
      return PaymentIncrements(
        id: $0.id,
        amount: amount,
        paymentIncrementableId: $0.paymentIncrementableId,
        paymentIncrementableType: $0.paymentIncrementableType,
        scheduledCollection: $0.scheduledCollection,
        state: $0.state,
        stateReason: $0.stateReason
      )
    }

    return BuildPaymentPlanEnvelope(
      projectIsPledgeOverTimeAllowed: projectIsPledgeOverTimeAllowed,
      amountIsPledgeOverTimeEligible: amountIsPledgeOverTimeEligible,
      paymentIncrements: paymentIncrements
    )
  }
}
