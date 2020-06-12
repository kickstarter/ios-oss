import Foundation

public struct SignInWithAppleMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation signInWithApple($input: SignInWithAppleInput!) {
      signInWithApple(input: $input) {
        apiAccessToken
        user {
          uid
        }
      }
    }
    """
  }
}
