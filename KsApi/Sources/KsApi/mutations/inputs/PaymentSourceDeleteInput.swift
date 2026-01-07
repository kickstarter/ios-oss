import Foundation

public struct PaymentSourceDeleteInput: GraphMutationInput {
  let paymentSourceId: String

  public init(paymentSourceId: String) {
    self.paymentSourceId = paymentSourceId
  }

  public func toInputDictionary() -> [String: Any] {
    return ["paymentSourceId": self.paymentSourceId]
  }
}
