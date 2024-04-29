import Foundation
import KsApi
import ReactiveSwift

public protocol StripeIntentServiceType {
  static func createPaymentIntent(for projectId: String, pledgeTotal: Double)
    -> SignalProducer<PaymentIntentEnvelope, ErrorEnvelope>
}

/// This is the module that creates either a Stripe payment intent or a setup intent.
public struct StripeIntentService: StripeIntentServiceType {
  /**
   Returns a signal producer that emits a `PaymentIntentEnvelope` or `ErrorEnvelope` value representing whether or not a payment intent was created and returned successfully.
   The returned producer emits once and completes.

   - parameter for: The types to register that we will request permissions for.
   - parameters:
     - projectId: The GraphID of a project
     - pledgeTotal: The final pledge total of the current pledge
   */

  public static func createPaymentIntent(
    for projectId: String,
    pledgeTotal: Double
  ) -> SignalProducer<PaymentIntentEnvelope, ErrorEnvelope> {
    AppEnvironment.current.apiService
      .createPaymentIntentInput(input: CreatePaymentIntentInput(
        projectId: projectId,
        amountDollars: String(format: "%.2f", pledgeTotal),
        digitalMarketingAttributed: nil
      ))
  }
}
