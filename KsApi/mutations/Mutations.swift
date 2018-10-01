import Foundation

public struct ChangePasswordMutation: GraphMutation {
  var input: GraphMutationInput

  public init(input: GraphMutationInput) {
    self.input = input
  }

  public var description: String {
    return """
    mutation UpdateUserPassword($input: UpdateUserAccountInput!) {\
      updateUserAccount(input: $input) {\
        clientMutationId\
      }\
    }
    """
  }
}
