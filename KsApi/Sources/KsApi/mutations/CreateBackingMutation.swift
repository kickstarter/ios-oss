import Foundation

public struct CreateBackingMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation createBacking($input: CreateBackingInput!) {
      createBacking(input: $input) {
        clientMutationId
        checkout {
          state
          id
          backing {
            requiresAction
            clientSecret
          }
        }
      }
    }
    """
  }
}
