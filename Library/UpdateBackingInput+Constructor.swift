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

    // Check if this is a change payment method and PLOT pledge; if so, only include paymentSourceId or applePay.
    let isChangePaymentMethodAndPlot = updateBackingData
      .pledgeContext == .changePaymentMethod && updateBackingData.backing.paymentIncrements.count > 0

    let shouldOmitAmount = updateBackingData.backing
      .isLatePledge || isFixPledge || isChangePaymentMethodAndPlot
    let shouldOmitLocationAndRewards = isFixPledge || isChangePaymentMethodAndPlot

    return UpdateBackingInput(
      amount: shouldOmitAmount ? nil : pledgeTotal,
      applePay: isApplePay ? updateBackingData.applePayParams : nil,
      id: backingId,
      locationId: shouldOmitLocationAndRewards ? nil : locationId,
      paymentSourceId: isApplePay ? nil : updateBackingData.paymentSourceId,
      rewardIds: shouldOmitLocationAndRewards ? nil : rewardIds,
      setupIntentClientSecret: updateBackingData.setupIntentClientSecret
    )
  }
}
