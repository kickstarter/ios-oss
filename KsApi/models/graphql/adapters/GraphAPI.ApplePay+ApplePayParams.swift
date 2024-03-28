import Foundation

extension GraphAPI.ApplePayInput {
  static func from(_ input: ApplePayParams?) -> GraphAPI.ApplePayInput? {
    guard let input = input else { return nil }
    return GraphAPI.ApplePayInput(
      token: input.token,
      paymentInstrumentName: input.paymentInstrumentName,
      paymentNetwork: input.paymentNetwork,
      transactionIdentifier: input.transactionIdentifier
    )
  }
}
