import Foundation
import KsApi
import PassKit

extension PKPaymentRequest {
  public static func paymentRequest(
    for project: Project,
    reward: Reward,
    pledgeAmount: Double,
    selectedShippingRule: ShippingRule?,
    merchantIdentifier: String,
    env: Environment = AppEnvironment.current
  ) -> PKPaymentRequest {
    let request = PKPaymentRequest()
    request.merchantIdentifier = merchantIdentifier
    request.supportedNetworks = env.applePayCapabilities.supportedNetworks(for: project)
    request.merchantCapabilities = .capability3DS
    request.countryCode = project.country.countryCode
    request.currencyCode = project.country.currencyCode
    request.shippingType = .shipping

    request.paymentSummaryItems = self.paymentSummaryItems(
      forProject: project,
      reward: reward,
      pledgeAmount: pledgeAmount,
      selectedShippingRule: selectedShippingRule
    )

    return request
  }

  private static func paymentSummaryItems(
    forProject project: Project,
    reward: Reward,
    pledgeAmount: Double,
    selectedShippingRule: ShippingRule?
  ) -> [PKPaymentSummaryItem] {
    var paymentSummaryItems: [PKPaymentSummaryItem] = []

    paymentSummaryItems.append(
      PKPaymentSummaryItem(
        label: reward.title ?? project.name,
        amount: NSDecimalNumber(value: pledgeAmount),
        type: .final
      )
    )

    if let selectedShippingRule = selectedShippingRule {
      paymentSummaryItems.append(
        PKPaymentSummaryItem(
          label: Strings.Shipping(),
          amount: NSDecimalNumber(value: selectedShippingRule.cost),
          type: .final
        )
      )
    }

    let total = paymentSummaryItems.reduce(NSDecimalNumber.zero) { accum, item in
      accum.adding(item.amount)
    }

    paymentSummaryItems.append(
      PKPaymentSummaryItem(
        label: Strings.Kickstarter_if_funded(),
        amount: total,
        type: .final
      )
    )

    return paymentSummaryItems
  }
}
