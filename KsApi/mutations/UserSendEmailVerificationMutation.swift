import Foundation

public struct UserSendEmailVerificationMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation userSendEmailVerification($input: UserSendEmailVerificationInput!) {
      updateUserProfile(input: $input) {
        clientMutationId
      }
    }
    """
  }
}
