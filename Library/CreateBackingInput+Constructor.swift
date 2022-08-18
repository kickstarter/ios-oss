import Foundation
import KsApi

extension CreateBackingInput {
  internal static func input(
    from createBackingData: CreateBackingData,
    isApplePay: Bool
  ) -> CreateBackingInput {
    let pledgeParams = sanitizedPledgeParameters(
      from: createBackingData.rewards,
      selectedQuantities: createBackingData.selectedQuantities,
      pledgeTotal: createBackingData.pledgeTotal,
      shippingRule: createBackingData.shippingRule
    )

    let setupIntentClientSecret = isApplePay ? nil : createBackingData
      .paymentSourceId == nil ? createBackingData.setupIntentClientSecret : nil
    let paymentSourceId = isApplePay ? nil : createBackingData
      .setupIntentClientSecret == nil ? createBackingData.paymentSourceId : nil

    return CreateBackingInput(
      amount: pledgeParams.pledgeTotal,
      applePay: isApplePay ? createBackingData.applePayParams : nil,
      locationId: pledgeParams.locationId,
      paymentSourceId: paymentSourceId,
      projectId: createBackingData.project.graphID,
      refParam: createBackingData.refTag?.description,
      rewardIds: pledgeParams.rewardIds,
      setupIntentClientSecret: setupIntentClientSecret
    )
  }
}
