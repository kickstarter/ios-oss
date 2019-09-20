import Foundation

public struct CreateApplePayBackingMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation createApplePayBacking($input: CreateApplePayBackingInput!) {
      createApplePayBacking(input: $input) {
        clientMutationId
      }
    }
    """
  }
}
