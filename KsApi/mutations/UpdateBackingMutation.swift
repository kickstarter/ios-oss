import Foundation

public struct UpdateBackingMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation createBacking($input: UpdateBackingInput!) {
      createBacking(input: $input) {
        checkout {
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
