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

    let pledgeParams
      = formattedPledgeParameters(from: project,
                                  reward: reward,
                                  pledgeAmount: pledgeAmount,
                                  selectedShippingRule: selectedShippingRule)

    return CreateBackingInput(
      amount: pledgeParams.pledgeTotal,
      locationId: pledgeParams.locationId,
      paymentSourceId: paymentSourceId,
      projectId: pledgeParams.projectId,
      rewardId: pledgeParams.rewardId,
      refParam: refTag?.description
    )
  }
}
