import KsApi
import PassKit

extension PKPaymentAuthorizationViewController {
  public static var merchantIdentifier: String {
    return Secrets.ApplePay.merchantIdentifier
  }

  public static var allSupportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .masterCard,
    .visa,
    .discover,
    .JCB,
    .chinaUnionPay
  ]

  public static func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: self.allSupportedNetworks)
  }

  public static func applePayDevice() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }

  public static func applePayCapable(for project: Project) -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(
      usingNetworks: PKPaymentAuthorizationViewController.supportedNetworks(for: project)
    )
  }

  public static func supportedNetworks(for project: Project) -> [PKPaymentNetwork] {
    guard let availableCardTypes = project.availableCardTypes else {
      return self.supportedNetworks(projectCountry: project.country)
    }

    return availableCardTypes
      .compactMap(GraphUserCreditCard.CreditCardType.init(rawValue:))
      .compactMap(self.pkPaymentNetwork(for:))
  }

  private static func supportedNetworks(projectCountry: Project.Country) -> [PKPaymentNetwork] {
    if projectCountry == Project.Country.us {
      return self.allSupportedNetworks
    } else {
      let unsupportedNetworks: Set<PKPaymentNetwork> = [.chinaUnionPay, .discover]
      let supportedNetworks: Set<PKPaymentNetwork> = Set.init(self.allSupportedNetworks)

      return Array(supportedNetworks.subtracting(unsupportedNetworks))
    }
  }

  private static func pkPaymentNetwork(for graphCreditCardType: GraphUserCreditCard.CreditCardType)
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
    case .diners:
      return nil
    case .generic:
      return nil
    }
  }
}
