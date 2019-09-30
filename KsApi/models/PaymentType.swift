import Foundation

// This type should be removed once the createBacking mutation is updated to automatically set this type
public enum PaymentType: String, Encodable {
  case creditCard = "CREDIT_CARD"
}
