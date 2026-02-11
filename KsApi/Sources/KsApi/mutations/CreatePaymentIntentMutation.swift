import Foundation

public struct CreatePaymentIntentMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation createPaymentIntent($input: CreatePaymentIntentInput!) {
      createPaymentIntent(input: $input) {
        clientSecret
        clientMutationId
      }
    }
    """
  }
}
