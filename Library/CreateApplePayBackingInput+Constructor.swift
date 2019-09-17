import Foundation
import KsApi

extension CreateApplePayBackingInput {
  internal static func input(
    from project: Project,
    reward: Reward,
    pledgeAmount: Double,
    selectedShippingRule: ShippingRule?,
    pkPaymentData: PKPaymentData,
    stripeToken: String,
    refTag: RefTag?
  ) -> CreateApplePayBackingInput {
    let pledgeAmountDecimal = Decimal(pledgeAmount)
    var shippingAmountDecimal: Decimal = Decimal()
    var shippingLocationId: String?

    if let shippingRule = selectedShippingRule, shippingRule.cost > 0 {
      shippingAmountDecimal = Decimal(shippingRule.cost)
      shippingLocationId = String(shippingRule.location.id)
    }

    let pledgeTotal = NSDecimalNumber(decimal: pledgeAmountDecimal + shippingAmountDecimal)
    let formattedPledgeTotal = Format.decimalCurrency(for: pledgeTotal.doubleValue)

    let rewardId = reward == Reward.noReward ? nil : reward.graphID

    return CreateApplePayBackingInput(
      amount: formattedPledgeTotal,
      locationId: shippingLocationId,
      paymentInstrumentName: pkPaymentData.displayName,
      paymentNetwork: pkPaymentData.network,
      projectId: project.graphID,
      refParam: refTag?.description,
      rewardId: rewardId,
      stripeToken: stripeToken,
      transactionIdentifier: pkPaymentData.transactionIdentifier
    )
  }
}
