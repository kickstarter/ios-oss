import Foundation

public struct CreateCheckoutInput: GraphMutationInput, Encodable {
  let projectId: String
  let amount: String?
  let locationId: String?
  let rewardIds: [String]
  let refParam: String?

  /**
   Initializes a CreateCheckout.

   - parameter projectId: The GraphID of the Project.
   - parameter amount: The amount.
   - parameter locationId: The optional ID of the ShippingRule's Location.
   - parameter rewardIds: The GraphIDs of the Rewards.
   - parameter refParam: The optional RefParam.
   */
  public init(
    projectId: String,
    amount: String?,
    locationId: String?,
    rewardIds: [String],
    refParam: String?
  ) {
    self.projectId = projectId
    self.amount = amount
    self.locationId = locationId
    self.rewardIds = rewardIds
    self.refParam = refParam
  }
}
