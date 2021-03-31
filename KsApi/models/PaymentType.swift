import Foundation

public enum PaymentType: String, Decodable {
  case applePay = "APPLE_PAY"
  case creditCard = "CREDIT_CARD"
  case googlePay = "ANDROID_PAY"

  public var accessibilityLabel: String? {
    switch self {
    case .applePay:
      return "Apple Pay"
    case .googlePay:
      return "Google Pay"
    case .creditCard:
      return nil
    }
  }

  public var trackingString: String? {
    switch self {
    case .applePay:
      return "apple_pay"
    case .googlePay:
      return nil
    case .creditCard:
      return "credit_card"
    }
  }
}
