import KsApi
import PassKit

extension PKPaymentAuthorizationViewController {
  public static var merchantIdentifier: String {
    return "merchant.com.kickstarter"
  }

  public static func applePayCapable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: PaymentNetworks.all)
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

    if (countryCode == "US" && project.country != Project.Country.us) ||
      countryCode != "US" {
      return PaymentNetworks.US.supported
    }

    return PaymentNetworks.all
  }

  public static var supportedNetworks: [PKPaymentNetwork] {
    return PaymentNetworks.all
  }
}

// MARK: - Payment networks

// swiftlint:disable private_over_fileprivate
private struct PaymentNetworks {
  fileprivate static var all: [PKPaymentNetwork] {
    return [.amex, .masterCard, .visa, .discover, .chinaUnionPay]
  }

  fileprivate struct US {
    fileprivate static var unsupported: [PKPaymentNetwork] {
      return [.chinaUnionPay, .discover]
    }

    fileprivate static var supported: [PKPaymentNetwork] {
      return PaymentNetworks.all.filter { !US.unsupported.contains($0) }
    }
  }
}

// swiftlint:enable private_over_fileprivate
