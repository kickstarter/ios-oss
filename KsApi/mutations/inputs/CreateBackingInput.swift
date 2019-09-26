import Foundation

public struct CreateBackingInput: GraphMutationInput {
  let amount: String
  let locationId: String?
  let paymentSourceId: String
  let projectId: String
  let rewardId: String?
  let refParam: String?

  public init(
    amount: String,
    locationId: String?,
    paymentSourceId: String,
    projectId: String,
    rewardId: String?,
    refParam: String?
  ) {
    self.amount = amount
    self.locationId = locationId
    self.paymentSourceId = paymentSourceId
    self.projectId = projectId
    self.rewardId = rewardId
    self.refParam = refParam
  }

  public func toInputDictionary() -> [String: Any] {
    var inputDictionary = [
      "amount": amount,
      "paymentSourceId": paymentSourceId,
      // swiftlint:disable:next line_length
      "paymentType": "credit_card", // this is temporary and will be removed once the mutation has been updated
      "projectId": projectId,
    ]

    if let locationId = self.locationId {
      inputDictionary["locationId"] = locationId
    }

    if let rewardId = self.rewardId {
      inputDictionary["rewardId"] = rewardId
    }

    if let refParam = self.refParam {
      inputDictionary["refParam"] = refParam
    }

    return inputDictionary
  }
}
