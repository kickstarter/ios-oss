import Foundation

public struct CreateCheckoutMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation createBacking($input: CreateCheckoutInput!) {
      createBacking(input: $input) {
        clientMutationId
        checkout {
          id
          paymentUrl
        }
      }
    }
    """
  }
}
