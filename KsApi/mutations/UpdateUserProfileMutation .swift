import Foundation

public struct UpdateUserProfileMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation updateUserCurrency($input: UpdateUserProfileInput!) {
      updateUserProfile(input: $input) {
        clientMutationId
      }
    }
    """
  }
}
