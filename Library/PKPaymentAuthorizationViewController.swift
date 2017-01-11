import PassKit

extension PKPaymentAuthorizationViewController {

  public static var merchantIdentifier: String {
    return "merchant.com.kickstarter"
  }

  public static var supportedNetworks: [PKPaymentNetwork] {
    return [.amex, .masterCard, .visa, .discover]
  }

  public static func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks)
  }

  public static func applePayDevice() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }
}
