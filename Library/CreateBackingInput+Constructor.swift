import Foundation
import KsApi

extension CreateBackingInput {
  internal static func input(
    from project: Project,
    reward: Reward,
    pledgeAmount: Double,
    selectedShippingRule: ShippingRule?,
    refTag: RefTag?,
    paymentSourceId: String
  ) -> CreateBackingInput {
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

    return CreateBackingInput(
      amount: formattedPledgeTotal,
      locationId: shippingLocationId,
      paymentSourceId: paymentSourceId,
      projectId: project.graphID,
      rewardId: rewardId,
      refParam: refTag?.description
    )
  }
}
