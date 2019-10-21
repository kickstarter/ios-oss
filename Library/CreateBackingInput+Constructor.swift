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
    let pledgeParams = sanitizedPledgeParameters(
        from: reward,
        pledgeAmount: pledgeAmount,
        selectedShippingRule: selectedShippingRule
      )

    return CreateBackingInput(
      amount: pledgeParams.pledgeTotal,
      locationId: pledgeParams.locationId,
      paymentSourceId: paymentSourceId,
      projectId: project.graphID,
      rewardId: pledgeParams.rewardId,
      refParam: refTag?.description
    )
  }
}
