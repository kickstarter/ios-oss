import Foundation

public enum Feature: String {
  case checkout = "ios_native_checkout"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .checkout: return "Native Checkout"
    }
  }
}
