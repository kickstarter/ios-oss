import Foundation
import KsApi

extension UpdateBackingInput {
  internal static func input(
    from updateBackingData: UpdateBackingData,
    isApplePay: Bool
  ) -> UpdateBackingInput {
    let backingId = updateBackingData.backing.graphID
    let (pledgeTotal, rewardIds, locationId) = sanitizedPledgeParameters(
      from: updateBackingData.rewards,
      selectedQuantities: updateBackingData.selectedQuantities,
      pledgeTotal: updateBackingData.pledgeTotal,
      shippingRule: updateBackingData.shippingRule
    )

    return UpdateBackingInput(
      amount: pledgeTotal,
      applePay: isApplePay ? updateBackingData.applePayParams : nil,
      id: backingId,
      locationId: locationId,
      paymentSourceId: isApplePay ? nil : updateBackingData.paymentSourceId,
      rewardIds: rewardIds,
      setupIntentClientSecret: updateBackingData.setupIntentClientSecret
    )
  }
}
