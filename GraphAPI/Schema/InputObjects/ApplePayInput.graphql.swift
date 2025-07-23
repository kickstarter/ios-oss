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
    token: String,
    paymentInstrumentName: String,
    paymentNetwork: String,
    transactionIdentifier: String
  ) {
    __data = InputDict([
      "token": token,
      "paymentInstrumentName": paymentInstrumentName,
      "paymentNetwork": paymentNetwork,
      "transactionIdentifier": transactionIdentifier
    ])
  }

  /// Stripe token
  public var token: String {
    get { __data["token"] }
    set { __data["token"] = newValue }
  }

  public var paymentInstrumentName: String {
    get { __data["paymentInstrumentName"] }
    set { __data["paymentInstrumentName"] = newValue }
  }

  public var paymentNetwork: String {
    get { __data["paymentNetwork"] }
    set { __data["paymentNetwork"] = newValue }
  }

  public var transactionIdentifier: String {
    get { __data["transactionIdentifier"] }
    set { __data["transactionIdentifier"] = newValue }
  }
}
