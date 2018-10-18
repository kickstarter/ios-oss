import Foundation

public struct ChangePasswordMutation: GraphMutation {
  var input: ChangePasswordInput

  public init(input: ChangePasswordInput) {
    self.input = input
  }

  public var description: String {
    return """
    mutation updateUserPassword($input: UpdateUserAccountInput!) {\
      updateUserAccount(input: $input) {\
        clientMutationId\
      }\
    }
    """
  }
}

public struct ChangeCurrencyMutation: GraphMutation {
  var input: ChangeCurrencyInput

  public init(input: ChangeCurrencyInput) {
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
