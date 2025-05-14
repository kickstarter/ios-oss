import Foundation

public enum PaymentType: String, Decodable {
  case applePay = "APPLE_PAY"
  case creditCard = "CREDIT_CARD"
  case googlePay = "ANDROID_PAY"
  case bankAccount = "BANK_ACCOUNT"

  public var accessibilityLabel: String? {
    switch self {
    case .applePay:
      return "Apple Pay"
    case .googlePay:
      return "Google Pay"
    case .bankAccount:
      return nil // TODO(MBL-2434): Use translated "bank account" string.
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
    case .bankAccount:
      return nil
    case .creditCard:
      return "credit_card"
    }
  }
}
