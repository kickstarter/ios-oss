import Foundation

public struct ApplePayParams: Encodable, Equatable {
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
