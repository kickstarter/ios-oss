@testable import Library
@testable import Stripe
@testable import StripePaymentSheet

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

  static let samplePaymentOptionsDisplayData: (PaymentSheet.PaymentOption)
    -> PaymentSheetPaymentOptionsDisplayData = { paymentOption in
      switch paymentOption {
      case let .saved(paymentMethod):
        return PaymentSheetPaymentOptionsDisplayData(image: .add, label: "••••1234")
      case .applePay, .new, .link:
        return PaymentSheetPaymentOptionsDisplayData(image: .add, label: "Unknown")
      }
    }
}
