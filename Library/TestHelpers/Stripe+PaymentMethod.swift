@testable import Stripe

extension STPPaymentMethod {
  static let visaStripePaymentMethod = STPPaymentMethod.decodedObject(fromAPIResponse: [
    "id": "_randomID123",
    "card": [
      "brand": "visa",
      "last4": "1234"
    ],
    "type": "card"
  ])

  static let amexStripePaymentMethod = STPPaymentMethod.decodedObject(fromAPIResponse: [
    "id": "_randomID123",
    "card": [
      "brand": "amex",
      "last4": "1234"
    ],
    "type": "card"
  ])

  static let sampleStringPaymentOption: (STPPaymentMethod) -> PaymentSheet.PaymentOption = { paymentMethod in
    PaymentSheet.PaymentOption.saved(paymentMethod: paymentMethod)
  }

  static let samplePaymentOptionsDisplayData: (PaymentSheet.PaymentOption) -> PaymentSheet.FlowController
    .PaymentOptionDisplayData = { paymentOption in
      PaymentSheet.FlowController.PaymentOptionDisplayData(paymentOption: paymentOption)
    }
}
