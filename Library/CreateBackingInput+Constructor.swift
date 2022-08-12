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

    return CreateBackingInput(
      amount: pledgeParams.pledgeTotal,
      applePay: isApplePay ? createBackingData.applePayParams : nil,
      locationId: pledgeParams.locationId,
      paymentSourceId: isApplePay ? nil : createBackingData.paymentSourceId,
      projectId: createBackingData.project.graphID,
      refParam: createBackingData.refTag?.description,
      rewardIds: pledgeParams.rewardIds,
      setupIntentClientSecret: nil
    )
  }
}
