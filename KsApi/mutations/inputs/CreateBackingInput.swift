import Foundation

public struct CreateBackingInput: GraphMutationInput, Encodable {
  let amount: String
  let applePay: ApplePayParams?
  let locationId: String?
  let paymentSourceId: String?
  let projectId: String
  let refParam: String?
  let rewardId: String

  /**
   Initializes a CreateBackingInput.

   - parameter amount: The optional amount.
   - parameter applePay: The optional ApplePayParams.
   - parameter locationId: The optional ID of the ShippingRule's Location.
   - parameter paymentSourceId: The optional ID of the PaymentSource.
   - parameter projectId: The GraphID of the Project.
   - parameter refParam: The optional RefParam.
   - parameter rewardId: The GraphID of the Reward.
   */
  public init(
    amount: String,
    applePay: ApplePayParams?,
    locationId: String?,
    paymentSourceId: String?,
    projectId: String,
    refParam: String?,
    rewardId: String
  ) {
    self.amount = amount
    self.applePay = applePay
    self.locationId = locationId
    self.paymentSourceId = paymentSourceId
    self.projectId = projectId
    self.refParam = refParam
    self.rewardId = rewardId
  }
}
