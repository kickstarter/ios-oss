import Foundation

public struct UpdateUserAccountMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation updateUserAccount($input: UpdateUserAccountInput!) {
      updateUserAccount(input: $input) {
        clientMutationId
      }
    }
    """
  }
}
