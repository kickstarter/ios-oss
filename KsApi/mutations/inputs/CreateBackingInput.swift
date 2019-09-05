import Foundation

public struct CreateBackingInput: GraphMutationInput {
  let projectId: String
  let amount: String
  let locationId: String?
  let rewardId: String?
  let paymentSourceId: String
  let paymentType: String

  public init(
    projectId: String,
    amount: String,
    locationId: String?,
    rewardId: String?,
    paymentSourceId: String,
    paymentType: String
  ) {
    self.projectId = projectId
    self.amount = amount
    self.locationId = locationId
    self.rewardId = rewardId
    self.paymentSourceId = paymentSourceId
    self.paymentType = paymentType
  }

  public func toInputDictionary() -> [String: Any] {
    var inputDictionary = [
      "projectId": projectId,
      "amount": amount,
      "paymentSourceId": paymentSourceId,
      "paymentType": paymentType
    ]

    if let locationId = self.locationId {
      inputDictionary["locationId"] = locationId
    }

    if let rewardId = self.rewardId {
      inputDictionary["rewardId"] = rewardId
    }

    return inputDictionary
  }
}
