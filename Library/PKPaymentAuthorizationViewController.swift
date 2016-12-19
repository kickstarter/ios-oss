import PassKit

extension PKPaymentAuthorizationViewController {

  public static var merchantIdentifier: String {
    return "merchant.com.kickstarter"
  }

  public static var supportedNetworks: [String] {
    return [
      PKPaymentNetwork.amex.rawValue, PKPaymentNetwork.masterCard.rawValue, PKPaymentNetwork.visa.rawValue, PKPaymentNetwork.discover.rawValue
    ]
  }

  public static func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks as! [PKPaymentNetwork])
  }

  public static func applePayDevice() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }
}
