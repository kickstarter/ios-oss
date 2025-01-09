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

    // Check if this is a fix errored pledge context. If it is, do not include fields that cannot
    // be changed; amount, locationId, and rewardIds.
    let isFixPledge = updateBackingData.pledgeContext == .fixPaymentMethod

    return UpdateBackingInput(
      amount: (updateBackingData.backing.isLatePledge || isFixPledge) ? nil : pledgeTotal,
      applePay: isApplePay ? updateBackingData.applePayParams : nil,
      id: backingId,
      locationId: isFixPledge ? nil : locationId,
      paymentSourceId: isApplePay ? nil : updateBackingData.paymentSourceId,
      rewardIds: isFixPledge ? nil : rewardIds,
      setupIntentClientSecret: updateBackingData.setupIntentClientSecret
    )
  }
}
