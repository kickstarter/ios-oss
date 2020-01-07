import Foundation
import Library
import KsApi
import PassKit

internal struct MockApplePayCapable: ApplePayCapableType {
  func allSupportedNetworks() -> [PKPaymentNetwork] {
    return [.visa, .masterCard, .amex]
  }

  func applePayCapable() -> Bool {
    return true
  }

  func applePayDevice() -> Bool {
    return true
  }

  func applePayCapable(for project: Project) -> Bool {
    return true
  }

  func supportedNetworks(for project: Project) -> [PKPaymentNetwork] {
    return [.visa, .masterCard, .amex]
  }
}
