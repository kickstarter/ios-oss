import Foundation
import GraphAPI

public extension GraphAPI.ApplePayInput {
  static func from(_ input: ApplePayParams?) -> GraphAPI.ApplePayInput? {
    guard let input = input else { return nil }
    return GraphAPI.ApplePayInput(
      paymentInstrumentName: input.paymentInstrumentName,
      paymentNetwork: input.paymentNetwork,
      token: input.token,
      transactionIdentifier: input.transactionIdentifier
    )
  }
}
