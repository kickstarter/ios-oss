import PassKit

extension PKPaymentAuthorizationViewController {

  public static var merchantIdentifier: String {
    return "merchant.com.kickstarter"
  }

  public static var supportedNetworks: [String] {
    return [
      PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkDiscover
    ]
  }

  public static func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(supportedNetworks)
  }

  public static func applePayDevice() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }
}
