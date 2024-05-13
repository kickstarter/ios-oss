@testable import KsApi
@testable import Library
import ReactiveSwift

public class MockStripeIntentService: StripeIntentServiceType {
  public private(set) var setupIntentRequests: Int = 0
  public private(set) var paymentIntentRequests: Int = 0

  public init() {}

  public func createPaymentIntent(
    for projectId: String,
    pledgeTotal: Double
  ) -> SignalProducer<PaymentIntentEnvelope, ErrorEnvelope> {
    assert(
      AppEnvironment.current.apiService as? MockService != nil,
      "apiService should be a Mock when testing"
    )

    self.paymentIntentRequests += 1

    return AppEnvironment.current.apiService
      .createPaymentIntentInput(input: CreatePaymentIntentInput(
        projectId: projectId,
        amountDollars: String(format: "%.2f", pledgeTotal),
        digitalMarketingAttributed: nil
      ))
  }

  public func createSetupIntent(
    for projectId: String?,
    context: GraphAPI.StripeIntentContextTypes
  ) -> SignalProducer<ClientSecretEnvelope, ErrorEnvelope> {
    assert(
      AppEnvironment.current.apiService as? MockService != nil,
      "apiService should be a Mock when testing"
    )

    self.setupIntentRequests += 1

    return AppEnvironment.current.apiService
      .createStripeSetupIntent(
        input: CreateSetupIntentInput(projectId: projectId, context: context)
      )
  }
}
