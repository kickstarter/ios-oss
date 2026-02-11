import Foundation

public struct CreatePaymentSourceMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation createPaymentSource($input: CreatePaymentSourceInput!) {
    createPaymentSource(input: $input) {
      clientMutationId
      errorMessage
      isSuccessful
      paymentSource {
          expirationDate
          id
          lastFour
          type
        }
      }
    }
    """
  }
}
