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

  private enum CodingKeys: String, CodingKey {
    case amount
    case locationId
    case paymentInstrumentName
    case paymentNetwork
    case projectId
    case rewardId
    case stripeToken = "token"
    case transactionIdentifier
  }

  public init(amount: String, locationId: Int?, paymentInstrumentName: String, paymentNetwork: String,
              projectId: Int, rewardId: Int?, stripeToken: String, transactionIdentifier: String) {
    self.amount = amount
    self.locationId = locationId
    self.paymentInstrumentName = paymentInstrumentName
    self.paymentNetwork = paymentNetwork
    self.projectId = projectId
    self.rewardId = rewardId
    self.stripeToken = stripeToken
    self.transactionIdentifier = transactionIdentifier
  }

  public func toInputDictionary() -> [String : Any] {
    do {
      let JSONObject = try JSONSerialization.jsonObject(with: JSONEncoder().encode(self), options: [])

      guard let jsonDictionary = JSONObject as? [String: Any] else {
        throw GraphError.jsonEncodingError
      }

      return jsonDictionary
    } catch {
      return [:]
    }
  }
}

extension CreateApplePayBackingInput: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.amount, forKey: .amount)
    try container.encode(self.paymentInstrumentName, forKey: .paymentInstrumentName)
    try container.encode(self.paymentNetwork, forKey: .paymentNetwork)
    try container.encode(String(self.projectId), forKey: .projectId)
    try container.encode(self.stripeToken, forKey: .stripeToken)
    try container.encode(self.transactionIdentifier, forKey: .transactionIdentifier)

    if let locationId = self.locationId {
      try container.encode("\(locationId)", forKey: .locationId)
    }

    if let rewardId = self.rewardId {
      try container.encode("\(rewardId)", forKey: .rewardId)
    }
  }
}
