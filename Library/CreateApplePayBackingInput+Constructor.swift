import Foundation
import KsApi

extension CreateApplePayBackingInput {
  internal static func input(
    from project: Project,
    reward: Reward,
    pledgeAmount: Double,
    selectedShippingRule: ShippingRule?,
    pkPaymentData: PKPaymentData,
    stripeToken: String,
    refTag: RefTag?
  ) -> CreateApplePayBackingInput {
    let pledgeParams
      = formattedPledgeParameters(from: project,
                                  reward: reward,
                                  pledgeAmount: pledgeAmount,
                                  selectedShippingRule: selectedShippingRule)

    return CreateApplePayBackingInput(
      amount: pledgeParams.pledgeTotal,
      locationId: pledgeParams.locationId,
      paymentInstrumentName: pkPaymentData.displayName,
      paymentNetwork: pkPaymentData.network,
      projectId: pledgeParams.projectId,
      refParam: refTag?.description,
      rewardId: pledgeParams.rewardId,
      stripeToken: stripeToken,
      transactionIdentifier: pkPaymentData.transactionIdentifier
    )
  }
}
