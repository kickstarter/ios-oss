import Foundation

public struct CreateApplePayBackingInput: GraphMutationInput {
  let amount: String
  let locationId: Int?
  let paymentInstrumentName: String
  let paymentNetwork: String
  let projectId: Int
  let rewardId: Int?
  let stripeToken: String
  let transactionIdentifier: String

  public init(
    amount: String, locationId: Int?, paymentInstrumentName: String, paymentNetwork: String,
    projectId: Int, rewardId: Int?, stripeToken: String, transactionIdentifier: String
  ) {
    self.amount = amount
    self.locationId = locationId
    self.paymentInstrumentName = paymentInstrumentName
    self.paymentNetwork = paymentNetwork
    self.projectId = projectId
    self.rewardId = rewardId
    self.stripeToken = stripeToken
    self.transactionIdentifier = transactionIdentifier
  }

  public func toInputDictionary() -> [String: Any] {
    var inputDictionary = [
      "amount": self.amount,
      "paymentInstrumentName": self.paymentInstrumentName,
      "paymentNetwork": self.paymentNetwork,
      "projectId": String(self.projectId),
      "token": self.stripeToken,
      "transactionIdentifier": self.transactionIdentifier
    ]

    if let locationId = self.locationId {
      inputDictionary["locationId"] = String(locationId)
    }

    if let rewardId = self.rewardId {
      inputDictionary["rewardId"] = String(rewardId)
    }

    return inputDictionary
  }
}
