import Foundation
import KsApi

extension UpdateBackingInput {
  internal static func input(
    from updateBackingData: UpdateBackingData
  ) -> UpdateBackingInput {
    let pledgeAmount: String? = updateBackingData.pledgeAmount.flatMap { pledgeAmount in
      pledgeAmountString(withAmount: pledgeAmount, shippingRule: updateBackingData.shippingRule)
    }
    let backingId: String = updateBackingData.backing.graphID
    let locationId: String? = updateBackingData.shippingRule.flatMap { "\($0.location.id)" }
    let rewardId: String? = updateBackingData.reward.graphID

    return UpdateBackingInput(
      amount: pledgeAmount,
      applePay: updateBackingData.applePayParams,
      id: backingId,
      locationId: locationId,
      paymentSourceId: updateBackingData.paymentSourceId,
      rewardId: rewardId
    )
  }
}

private func pledgeAmountString(withAmount amount: Double, shippingRule: ShippingRule?) -> String {
  let pledgeAmountDecimal = Decimal(amount)
  var shippingAmountDecimal: Decimal = Decimal()

  if let shippingRule = shippingRule, shippingRule.cost > 0 {
    shippingAmountDecimal = Decimal(shippingRule.cost)
  }

  let pledgeTotal = NSDecimalNumber(decimal: pledgeAmountDecimal + shippingAmountDecimal)
  let formattedPledgeTotal = Format.decimalCurrency(for: pledgeTotal.doubleValue)

  return formattedPledgeTotal
}
