import Foundation
import GraphAPI

extension GraphAPI.PaymentSourceDeleteInput {
  static func from(_ input: PaymentSourceDeleteInput) -> GraphAPI.PaymentSourceDeleteInput {
    return GraphAPI.PaymentSourceDeleteInput(paymentSourceId: input.paymentSourceId)
  }
}
