import Foundation

public struct CompleteOrderInput: GraphMutationInput, Encodable {
  let projectId: String
  let stripePaymentMethodId: String?
  let paymentSourceReusable: Bool?
  let paymentMethodTypes: [String]?

  /**
   Initializes a CompleteOrderInput.
   */
  public init(projectId: String, stripePaymentMethodId: String?, paymentSourceReusable: Bool? = nil, paymentMethodTypes: [String]? = nil) {
    self.projectId = projectId
    self.stripePaymentMethodId = stripePaymentMethodId
    self.paymentSourceReusable = paymentSourceReusable
    self.paymentMethodTypes = paymentMethodTypes
  }
}
