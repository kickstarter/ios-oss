import Foundation

public struct UpdateBackingInput: GraphMutationInput, Encodable {
  let amount: String?
  let applePay: ApplePay?
  let id: String
  let locationId: String?
  let paymentSourceId: String?
  let rewardId: String?

  public struct ApplePay: Encodable {
    let paymentInstrumentName: String
    let paymentNetwork: String
    let transactionIdentifier: String
    let token: String

    public init(
      paymentInstrumentName: String,
      paymentNetwork: String,
      transactionIdentifier: String,
      token: String
    ) {
      self.paymentInstrumentName = paymentInstrumentName
      self.paymentNetwork = paymentNetwork
      self.transactionIdentifier = transactionIdentifier
      self.token = token
    }
  }

  public init(
    amount: String?,
    applePay: ApplePay?,
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

  public func toInputDictionary() -> [String: Any] {
    return self.dictionaryRepresentation ?? [:]
  }
}
