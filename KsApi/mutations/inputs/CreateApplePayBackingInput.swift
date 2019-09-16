import Foundation

public struct CreateApplePayBackingInput: GraphMutationInput {
  let amount: String
  let locationId: String?
  let paymentInstrumentName: String
  let paymentNetwork: String
  let projectId: String
  let refParam: String?
  let rewardId: String?
  let stripeToken: String
  let transactionIdentifier: String

  public init(
    amount: String, locationId: String?, paymentInstrumentName: String, paymentNetwork: String,
    projectId: String, refParam: String?, rewardId: String?, stripeToken: String,
    transactionIdentifier: String
  ) {
    self.amount = amount
    self.locationId = locationId
    self.paymentInstrumentName = paymentInstrumentName
    self.paymentNetwork = paymentNetwork
    self.projectId = projectId
    self.refParam = refParam
    self.rewardId = rewardId
    self.stripeToken = stripeToken
    self.transactionIdentifier = transactionIdentifier
  }

  public func toInputDictionary() -> [String: Any] {
    var inputDictionary = [
      "amount": self.amount,
      "paymentInstrumentName": self.paymentInstrumentName,
      "paymentNetwork": self.paymentNetwork,
      "projectId": self.projectId,
      "token": self.stripeToken,
      "transactionIdentifier": self.transactionIdentifier
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
