import Foundation

public struct CreateSetupIntentMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    let desc = """
    mutation CreateSetupIntent($input: CreateSetupIntentInput!) {
      createSetupIntent(input: $input) {
        clientSecret
      }
    }
    """

    return desc
  }
}
