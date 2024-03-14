import Foundation
import KsApi
import PassKit

extension PKPaymentRequest {
  public static func paymentRequest(
    for project: Project,
    reward: Reward,
    allRewardsTotal: Double,
    additionalPledgeAmount: Double,
    allRewardsShippingTotal: Double,
    merchantIdentifier: String
  ) -> PKPaymentRequest {
    let request = PKPaymentRequest()
    request.merchantIdentifier = merchantIdentifier
    request.supportedNetworks = AppEnvironment.current.applePayCapabilities.supportedNetworks(for: project)
    request.merchantCapabilities = .capability3DS
    request.countryCode = project.country.countryCode
    request.currencyCode = projectCountry(forCurrency: project.stats.currency)?.currencyCode ?? project
      .country.currencyCode
    request.shippingType = .shipping

    request.paymentSummaryItems = self.paymentSummaryItems(
      reward: reward,
      allRewardsTotal: allRewardsTotal,
      additionalPledgeAmount: additionalPledgeAmount,
      allRewardsShippingTotal: allRewardsShippingTotal,
      postCampaignPledgingActive: featurePostCampaignPledgeEnabled() && project.isInPostCampaignPledgingPhase
    )

    return request
  }

  private static func paymentSummaryItems(
    reward: Reward,
    allRewardsTotal: Double,
    additionalPledgeAmount: Double,
    allRewardsShippingTotal: Double,
    postCampaignPledgingActive: Bool
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
        label: postCampaignPledgingActive ? Strings.Kickstarter_payment_summary() : Strings
          .Kickstarter_if_funded(),
        amount: total,
        type: .final
      )
    )

    return paymentSummaryItems
  }
}
