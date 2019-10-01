import Foundation

public struct UpdateBackingInput: GraphMutationInput, Encodable {
  let amount: String?
  let applePay: ApplePayParams?
  let id: String
  let locationId: String?
  let paymentSourceId: String?
  let rewardId: String?

  public init(
    amount: String?,
    applePay: ApplePayParams?,
    id: String,
    locationId: String?,
    paymentSourceId: String?,
    rewardId: String?
  ) {
    self.amount = amount
    self.applePay = applePay
    self.id = id
    self.locationId = locationId
    self.paymentSourceId = paymentSourceId
    self.rewardId = rewardId
  }
}
