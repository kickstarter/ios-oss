import Foundation

public struct ChangeEmailMutation: GraphMutation {
  var input: ChangeEmailInput

  public init(input: ChangeEmailInput) {
    self.input = input
  }

  public var description: String {
    return """
    mutation updateUserEmail($input: UpdateUserAccountInput!) {\
      updateUserAccount(input: $input) {\
        clientMutationId\
      }\
    }
    """
  }
}
