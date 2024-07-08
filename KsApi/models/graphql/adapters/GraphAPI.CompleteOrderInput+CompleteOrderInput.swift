import Foundation

extension GraphAPI.CompleteOrderInput {
  static func from(_ input: CompleteOrderInput) -> GraphAPI.CompleteOrderInput {
    return GraphAPI.CompleteOrderInput(
      projectId: input.projectId,
      stripePaymentMethodId: input.stripePaymentMethodId,
      paymentSourceReusable: input.paymentSourceReusable,
      paymentMethodTypes: input.paymentMethodTypes
    )
  }
}
