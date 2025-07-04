import Foundation

public struct UpdateBackingInput: GraphMutationInput, Encodable {
  let amount: String?
  let applePay: ApplePayParams?
  let id: String
  let incremental: Bool
  let locationId: String?
  let paymentSourceId: String?
  let rewardIds: [String]?
  let setupIntentClientSecret: String?

  /**
   Initializes an UpdateBackingInput.

   - parameter amount: The optional amount to update.
   - parameter applePay: The optional ApplePayParams to update.
   - parameter id: The GraphID of the Backing.
   - parameter locationId: The optional ID of the ShippingRule's Location.
   - parameter incremental: The Boolean that represents the type of backing made. Regular or Incremental (PLOT).
   - parameter paymentSourceId: The optional ID of the PaymentSource.
   - parameter rewardIds: The optional GraphIDs of the backed Rewards.
   - parameter setupIntentClientSecret: The optional ID of the Stripe provided payment sheet card.
   */
  public init(
    amount: String?,
    applePay: ApplePayParams?,
    id: String,
    incremental: Bool,
    locationId: String?,
    paymentSourceId: String?,
    rewardIds: [String]?,
    setupIntentClientSecret: String?
  ) {
    self.amount = amount
    self.applePay = applePay
    self.id = id
    self.incremental = incremental
    self.locationId = locationId
    self.paymentSourceId = paymentSourceId
    self.rewardIds = rewardIds
    self.setupIntentClientSecret = setupIntentClientSecret
  }
}
