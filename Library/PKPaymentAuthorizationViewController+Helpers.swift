import KsApi
import PassKit

extension PKPaymentAuthorizationViewController {
  public static var merchantIdentifier: String {
    return Secrets.ApplePay.merchantIdentifier
  }

  public static var allSupportedNetworks: [PKPaymentNetwork] = [.amex,
                                                                .masterCard,
                                                                .visa,
                                                                .discover,
                                                                .chinaUnionPay]

  public static func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: allSupportedNetworks)
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
      return supportedNetworks(projectCountry: project.country)
    }

    return availableCardTypes
      .compactMap { cardType in PKPaymentNetwork(rawValue: cardType) }
  }


  private static func supportedNetworks(projectCountry: Project.Country) -> [PKPaymentNetwork] {
    if projectCountry == Project.Country.us {
      return allSupportedNetworks
    } else {
      let unsupportedNetworks: Set<PKPaymentNetwork> = [.chinaUnionPay, .discover]
      let supportedNetworks: Set<PKPaymentNetwork> = Set.init(allSupportedNetworks)

      return Array(supportedNetworks.subtracting(unsupportedNetworks))
    }
  }
}

