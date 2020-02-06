import Foundation

public struct UpdateBackingMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation updateBacking($input: UpdateBackingInput!) {
      updateBacking(input: $input) {
        checkout {
          id
          state
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
