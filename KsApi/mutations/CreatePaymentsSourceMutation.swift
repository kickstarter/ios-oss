import Foundation

public struct CreatePaymentSourceMutations<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation createPaymentSource($input: CreatePaymentSourceInput!) {
    createPaymentSource(input: $input) {
      clientMutationId\
      }
    }
    """
  }
}
