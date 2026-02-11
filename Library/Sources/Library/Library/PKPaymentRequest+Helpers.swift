import Foundation
import KsApi
import PassKit

extension PKPaymentRequest {
  private static func paymentRequest(for project: Project, merchantIdentifier: String) -> PKPaymentRequest {
    let request = PKPaymentRequest()
    request.merchantIdentifier = merchantIdentifier
    request.supportedNetworks = AppEnvironment.current.applePayCapabilities.supportedNetworks(for: project)
    request.merchantCapabilities = .capability3DS
    request.countryCode = project.country.countryCode
    request.currencyCode = projectCountry(forCurrency: project.stats.projectCurrency)?.currencyCode ?? project
      .country.currencyCode
    request.shippingType = .shipping
    return request
  }

  public static func paymentRequest(
    for project: Project,
    reward: Reward,
    allRewardsTotal: Double,
    additionalPledgeAmount: Double,
    allRewardsShippingTotal: Double,
    merchantIdentifier: String
  ) -> PKPaymentRequest {
    let request = self.paymentRequest(for: project, merchantIdentifier: merchantIdentifier)

    request.paymentSummaryItems = self.paymentSummaryItems(
      reward: reward,
      allRewardsTotal: allRewardsTotal,
      additionalPledgeAmount: additionalPledgeAmount,
      allRewardsShippingTotal: allRewardsShippingTotal
    )

    return request
  }

  public static func paymentRequest(
    for data: PostCampaignPaymentAuthorizationData
  ) -> PKPaymentRequest {
    let request = self.paymentRequest(for: data.project, merchantIdentifier: data.merchantIdentifier)
    request.paymentSummaryItems = self.paymentSummaryItems(for: data)
    return request
  }

  private static func paymentSummaryItems(
    reward: Reward,
    allRewardsTotal: Double,
    additionalPledgeAmount: Double,
    allRewardsShippingTotal: Double
  ) -> [PKPaymentSummaryItem] {
    var paymentSummaryItems: [PKPaymentSummaryItem] = []

    if !reward.isNoReward {
      paymentSummaryItems.append(
        PKPaymentSummaryItem(
          label: Strings.activity_creator_reward(),
          amount: NSDecimalNumber(value: allRewardsTotal),
          type: .final
        )
      )

      let title = Strings.Bonus()

      paymentSummaryItems.append(
        PKPaymentSummaryItem(
          label: title,
          amount: NSDecimalNumber(value: additionalPledgeAmount),
          type: .final
        )
      )
    } else {
      paymentSummaryItems.append(
        PKPaymentSummaryItem(
          label: Strings.Total(),
          amount: NSDecimalNumber(value: additionalPledgeAmount),
          type: .final
        )
      )
    }

    if reward.shipping.enabled {
      paymentSummaryItems.append(
        PKPaymentSummaryItem(
          label: Strings.Shipping(),
          amount: NSDecimalNumber(value: allRewardsShippingTotal),
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

  private static func paymentSummaryItems(
    for data: PostCampaignPaymentAuthorizationData
  ) -> [PKPaymentSummaryItem] {
    var paymentSummaryItems: [PKPaymentSummaryItem] = []

    paymentSummaryItems.append(
      PKPaymentSummaryItem(
        label: data.hasNoReward ? Strings.Total() : Strings.activity_creator_reward(),
        amount: NSDecimalNumber(value: data.subtotal),
        type: .final
      )
    )

    if data.bonus > 0 {
      paymentSummaryItems.append(
        PKPaymentSummaryItem(
          label: Strings.Bonus(),
          amount: NSDecimalNumber(value: data.bonus),
          type: .final
        )
      )
    }

    if data.shipping > 0 {
      paymentSummaryItems.append(
        PKPaymentSummaryItem(
          label: Strings.Shipping(),
          amount: NSDecimalNumber(value: data.shipping),
          type: .final
        )
      )
    }

    paymentSummaryItems.append(
      PKPaymentSummaryItem(
        label: Strings.Kickstarter_payment_summary(),
        amount: NSDecimalNumber(value: data.total),
        type: .final
      )
    )

    return paymentSummaryItems
  }
}
