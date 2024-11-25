import Foundation

public struct CreateBackingInput: GraphMutationInput, Encodable {
  let amount: String
  let applePay: ApplePayParams?
  let incremental: Bool?
  let locationId: String?
  let paymentSourceId: String?
  let projectId: String
  let refParam: String?
  let rewardIds: [String]
  let setupIntentClientSecret: String?

  /**
   Initializes a CreateBackingInput.

   - parameter amount: The amount.
   - parameter applePay: The optional ApplePayParams.
   - parameter incremental: The optional Bool indicating whether pledge over time has been selected..
   - parameter locationId: The optional ID of the ShippingRule's Location.
   - parameter paymentSourceId: The optional ID of the PaymentSource.
   - parameter projectId: The GraphID of the Project.
   - parameter refParam: The optional RefParam.
   - parameter rewardIds: The GraphIDs of the Rewards.
   - parameter setupIntentClientSecret: The optional ID of the Stripe provided payment sheet card.
   */
  public init(
    amount: String,
    applePay: ApplePayParams?,
    incremental: Bool?,
    locationId: String?,
    paymentSourceId: String?,
    projectId: String,
    refParam: String?,
    rewardIds: [String],
    setupIntentClientSecret: String?
  ) {
    self.amount = amount
    self.applePay = applePay
    self.incremental = incremental
    self.locationId = locationId
    self.paymentSourceId = paymentSourceId
    self.projectId = projectId
    self.refParam = refParam
    self.rewardIds = rewardIds
    self.setupIntentClientSecret = setupIntentClientSecret
  }
}
