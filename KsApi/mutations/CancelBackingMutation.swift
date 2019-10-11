import Foundation

final class CancelBackingMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation cancelBacking($input: CancelBackingInput!) {
      cancelBacking(input: $input) {
        clientMutationId
      }
    }
    """
  }
}
