import Foundation

public struct CreateBackingInput: GraphMutationInput {
  let amount: String
  let locationId: String?
  let paymentSourceId: String
  let paymentType: String
  let projectId: String
  let rewardId: String?


  public init(
    amount: String,
    locationId: String?,
    paymentSourceId: String,
    paymentType: String,
    projectId: String,
    rewardId: String?
  ) {
    self.amount = amount
    self.locationId = locationId
    self.paymentSourceId = paymentSourceId
    self.paymentType = paymentType
    self.projectId = projectId
    self.rewardId = rewardId
  }

  public func toInputDictionary() -> [String: Any] {
    var inputDictionary = [
      "amount": amount,
      "paymentSourceId": paymentSourceId,
      "paymentType": paymentType,
      "projectId": projectId
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
