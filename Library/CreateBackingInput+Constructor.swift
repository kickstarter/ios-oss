import Foundation
import KsApi

extension CreateBackingInput {
  internal static func input(
    from createBackingData: CreateBackingData,
    isApplePay: Bool
  ) -> CreateBackingInput {
    let pledgeParams = sanitizedPledgeParameters(
      from: createBackingData.reward,
      pledgeAmount: createBackingData.pledgeAmount,
      shippingRule: createBackingData.shippingRule
    )

    return CreateBackingInput(
      amount: pledgeParams.pledgeTotal,
      applePay: isApplePay ? createBackingData.applePayParams : nil,
      locationId: pledgeParams.locationId,
      paymentSourceId: isApplePay ? nil : createBackingData.paymentSourceId,
      projectId: createBackingData.project.graphID,
      refParam: createBackingData.refTag?.description,
      rewardId: pledgeParams.rewardId
    )
  }
}
