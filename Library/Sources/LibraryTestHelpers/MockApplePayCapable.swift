import Foundation
import KsApi
import Library
import PassKit

internal struct MockApplePayCapabilities: ApplePayCapabilitiesType {
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

  func applePayCapable(for _: Project) -> Bool {
    return self.isApplePayCapableForProject
  }

  func supportedNetworks(for _: Project) -> [PKPaymentNetwork] {
    return self.supportedNetworksForProject
  }
}
