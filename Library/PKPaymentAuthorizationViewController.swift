import KsApi
import PassKit

extension PKPaymentAuthorizationViewController {

  public static var merchantIdentifier: String {
    return "merchant.com.kickstarter"
  }

  public static func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks)
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

    let countryCode = AppEnvironment.current.countryCode

    if countryCode == "US" && project.country != Project.Country.us ||
      countryCode != "US" {
      return PKPaymentAuthorizationViewController.supportedNetworks.filter { $0 != .discover }
    }

    return PKPaymentAuthorizationViewController.supportedNetworks
  }

  public static var supportedNetworks: [PKPaymentNetwork] {
    return [.amex, .masterCard, .visa, .discover]
  }
}
