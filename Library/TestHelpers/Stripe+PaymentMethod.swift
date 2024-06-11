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
    PaymentSheet.PaymentOption.saved(paymentMethod: paymentMethod, confirmParams: nil)
  }

  static let samplePaymentOptionsDisplayData: (PaymentSheet.PaymentOption)
    -> PaymentSheetPaymentOptionsDisplayData = { paymentOption in
      switch paymentOption {
      case let .saved(paymentMethod, _):
        return PaymentSheetPaymentOptionsDisplayData(image: .add, label: "••••1234")
      case .applePay, .new, .link, .external:
        return PaymentSheetPaymentOptionsDisplayData(image: .add, label: "Unknown")
      }
    }
}
