import Foundation

public struct ApplePayParams: Encodable, Equatable {
  public let paymentMethodId: String?
  let paymentInstrumentName: String
  let paymentNetwork: String
  let transactionIdentifier: String
  let token: String

  public init(
    paymentMethodId: String? = nil,
    paymentInstrumentName: String,
    paymentNetwork: String,
    transactionIdentifier: String,
    token: String
  ) {
    self.paymentMethodId = paymentMethodId
    self.paymentInstrumentName = paymentInstrumentName
    self.paymentNetwork = paymentNetwork
    self.transactionIdentifier = transactionIdentifier
    self.token = token
  }
}
