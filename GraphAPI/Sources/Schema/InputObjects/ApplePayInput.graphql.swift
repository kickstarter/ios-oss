// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Necessary fields for Apple Pay
public struct ApplePayInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    paymentInstrumentName: String,
    paymentNetwork: String,
    token: String,
    transactionIdentifier: String
  ) {
    __data = InputDict([
      "paymentInstrumentName": paymentInstrumentName,
      "paymentNetwork": paymentNetwork,
      "token": token,
      "transactionIdentifier": transactionIdentifier
    ])
  }

  /// Name of the payment instrument used in Apple Pay
  public var paymentInstrumentName: String {
    get { __data["paymentInstrumentName"] }
    set { __data["paymentInstrumentName"] = newValue }
  }

  /// Payment network of the card used in Apple Pay
  public var paymentNetwork: String {
    get { __data["paymentNetwork"] }
    set { __data["paymentNetwork"] = newValue }
  }

  /// Stripe token
  public var token: String {
    get { __data["token"] }
    set { __data["token"] = newValue }
  }

  /// Apple Pay transaction identifier
  public var transactionIdentifier: String {
    get { __data["transactionIdentifier"] }
    set { __data["transactionIdentifier"] = newValue }
  }
}
