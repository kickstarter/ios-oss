import Foundation
import KsApi

extension UpdateBackingInput {
  internal static func input(
    from updateBackingData: UpdateBackingData,
    isApplePay: Bool
  ) -> UpdateBackingInput {
    // For pledges that only change or fix the payment method,
    // we skip amount, rewards, and shipping info.
    if updateBackingData.pledgeContext == .changePaymentMethod || updateBackingData
      .pledgeContext == .fixPaymentMethod {
      return self.baseInput(
        from: updateBackingData,
        isApplePay: isApplePay,
        amount: nil,
        rewardIds: nil,
        locationId: nil
      )
    }

    // For regular pledge updates (e.g. update reward, amount, or shipping),
    // we include all relevant info unless it's a late pledge (omit amount).
    return self.buildFullBackingInput(from: updateBackingData, isApplePay: isApplePay)
  }

  private static func buildFullBackingInput(
    from updateBackingData: UpdateBackingData,
    isApplePay: Bool
  ) -> UpdateBackingInput {
    let (pledgeTotal, rewardIds, locationId) = sanitizedPledgeParameters(
      from: updateBackingData.rewards,
      selectedQuantities: updateBackingData.selectedQuantities,
      pledgeTotal: updateBackingData.pledgeTotal,
      shippingRule: updateBackingData.shippingRule
    )

    return self.baseInput(
      from: updateBackingData,
      isApplePay: isApplePay,
      amount: updateBackingData.backing.isLatePledge ? nil : pledgeTotal,
      rewardIds: rewardIds,
      locationId: locationId
    )
  }

  private static func baseInput(
    from updateBackingData: UpdateBackingData,
    isApplePay: Bool,
    amount: String?,
    rewardIds: [String]?,
    locationId: String?
  ) -> UpdateBackingInput {
    return UpdateBackingInput(
      amount: amount,
      applePay: isApplePay ? updateBackingData.applePayParams : nil,
      id: updateBackingData.backing.graphID,
      locationId: locationId,
      paymentSourceId: isApplePay ? nil : updateBackingData.paymentSourceId,
      rewardIds: rewardIds,
      setupIntentClientSecret: updateBackingData.setupIntentClientSecret
    )
  }
}
