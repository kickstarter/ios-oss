import Argo
import Foundation

public enum PaymentType: String, Swift.Decodable {
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
}

extension PaymentType: Argo.Decodable {}
