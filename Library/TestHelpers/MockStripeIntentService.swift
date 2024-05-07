@testable import KsApi
@testable import Library
import ReactiveSwift

public struct StripeIntentRequestTestData: Equatable {
  let projectId: String?
  let pledgeTotal: Double?
  let paymentIntentEnvelope: PaymentIntentEnvelope?
  let context: GraphAPI.StripeIntentContextTypes?
  let clientSeretEnvelope: ClientSecretEnvelope?
}

public class MockStripeIntentService: StripeIntentServiceType {
  public private(set) var intentRequests = [StripeIntentRequestTestData]()

  public init() {}

  public func createPaymentIntent(
    for projectId: String,
    pledgeTotal: Double
  ) -> SignalProducer<PaymentIntentEnvelope, ErrorEnvelope> {
    let paymentIntentEnvelope = PaymentIntentEnvelope(clientSecret: "test")

    self.intentRequests.append(StripeIntentRequestTestData(
      projectId: projectId,
      pledgeTotal: pledgeTotal,
      paymentIntentEnvelope: paymentIntentEnvelope,
      context: nil,
      clientSeretEnvelope: nil
    ))

    return SignalProducer(value: paymentIntentEnvelope)
  }

  public func createSetupIntent(
    for projectId: String?,
    context: GraphAPI.StripeIntentContextTypes
  ) -> SignalProducer<ClientSecretEnvelope, ErrorEnvelope> {
    let clientSecretEnvelope = ClientSecretEnvelope(clientSecret: "test")

    self.intentRequests.append(StripeIntentRequestTestData(
      projectId: projectId,
      pledgeTotal: nil,
      paymentIntentEnvelope: nil,
      context: context,
      clientSeretEnvelope: clientSecretEnvelope
    ))

    return SignalProducer(value: clientSecretEnvelope)
  }
}
