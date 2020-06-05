import Foundation
import KsApi
import PassKit

public protocol ApplePayCapabilitiesType {
  /*
   Returns an array of all KSR supported networks
   */
  func allSupportedNetworks() -> [PKPaymentNetwork]
  /*
   Returns whether the current device is capable of making payments using the list of allSupportedNetworks()
   */
  func applePayCapable() -> Bool
  /*
   Returns whether the current device is capable of making Apple Pay payments with any network
   */
  func applePayDevice() -> Bool

  /*
   Returns whether the current device is capable of making
   Apple Pay payments with the networks defined by the project's availableCardTypes

   parameters:
   - project: the project to use for determining supported card types
   */
  func applePayCapable(for project: Project) -> Bool

  /*
   Returns an array of supported PKPaymentNetworks
   determined from the project's list of availableCardTypes

   If the project does not have a list of availableCardTypes,
   allSupportedNetworks() is used

   parameters:
   - project: the project to use for determining supported card types
   */
  func supportedNetworks(for project: Project) -> [PKPaymentNetwork]
}

public struct ApplePayCapabilities: ApplePayCapabilitiesType {
  public init() {}

  public func allSupportedNetworks() -> [PKPaymentNetwork] {
    return [
      .amex,
      .masterCard,
      .visa,
      .discover,
      .JCB,
      .chinaUnionPay
    ]
  }

  public func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: self.allSupportedNetworks())
  }

  public func applePayDevice() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }

  public func applePayCapable(for project: Project) -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(
      usingNetworks: self.supportedNetworks(for: project)
    )
  }

  public func supportedNetworks(for project: Project) -> [PKPaymentNetwork] {
    guard let availableCardTypes = project.availableCardTypes else {
      return self.supportedNetworks(projectCountry: project.country)
    }

    return availableCardTypes
      .compactMap(CreditCardType.init(rawValue:))
      .compactMap(ApplePayCapabilities.pkPaymentNetwork(for:))
  }

  internal func supportedNetworks(projectCountry: Project.Country) -> [PKPaymentNetwork] {
    let allSupportedNetworks = self.allSupportedNetworks()

    if projectCountry == Project.Country.us {
      return allSupportedNetworks
    } else {
      let unsupportedNetworks: Set<PKPaymentNetwork> = [.chinaUnionPay, .discover]
      let supportedNetworks: Set<PKPaymentNetwork> = Set.init(allSupportedNetworks)

      return Array(supportedNetworks.subtracting(unsupportedNetworks))
    }
  }

  private static func pkPaymentNetwork(for graphCreditCardType: CreditCardType)
    -> PKPaymentNetwork? {
    switch graphCreditCardType {
    case .amex:
      return PKPaymentNetwork.amex
    case .discover:
      return PKPaymentNetwork.discover
    case .jcb:
      return PKPaymentNetwork.JCB
    case .mastercard:
      return PKPaymentNetwork.masterCard
    case .unionPay:
      return PKPaymentNetwork.chinaUnionPay
    case .visa:
      return PKPaymentNetwork.visa
    case .diners, .generic:
      return nil
    }
  }
}
