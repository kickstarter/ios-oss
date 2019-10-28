import Foundation
import KsApi

extension UpdateBackingInput {
  internal static func input(
    from updateBackingData: UpdateBackingData,
    isApplePay: Bool
  ) -> UpdateBackingInput {
    let backingId = updateBackingData.backing.graphID
    let (pledgeTotal, rewardId, locationId) = sanitizedPledgeParameters(
      from: updateBackingData.reward,
      pledgeAmount: updateBackingData.pledgeAmount,
      shippingRule: updateBackingData.shippingRule
    )

    return UpdateBackingInput(
      amount: pledgeTotal,
      applePay: isApplePay ? updateBackingData.applePayParams : nil,
      id: backingId,
      locationId: locationId,
      paymentSourceId: isApplePay ? nil : updateBackingData.paymentSourceId,
      rewardId: rewardId
    )
  }
}
