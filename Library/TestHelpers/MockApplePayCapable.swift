import Foundation
import Library
import KsApi
import PassKit

internal struct MockApplePayCapable: ApplePayCapableType {
  var supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
  var isApplePayCapable: Bool = true
  var isApplePayDevice: Bool = true
  var isApplePayCapableForProject: Bool = true
  var supportedNetworksForProject: [PKPaymentNetwork] = [.visa, .masterCard, .amex]

  func allSupportedNetworks() -> [PKPaymentNetwork] {
    return self.supportedNetworks
  }

  func applePayCapable() -> Bool {
    return self.isApplePayCapable
  }

  func applePayDevice() -> Bool {
    return self.isApplePayDevice
  }

  func applePayCapable(for project: Project) -> Bool {
    return self.isApplePayCapableForProject
  }

  func supportedNetworks(for project: Project) -> [PKPaymentNetwork] {
    return self.supportedNetworksForProject
  }
}
