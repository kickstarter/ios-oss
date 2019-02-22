import Foundation

public struct CreatePasswordInput: GraphMutationInput {
  let password: String
  let passwordConfirmation: String

  public init(password: String, passwordConfirmation: String) {
    self.password = password
    self.passwordConfirmation = passwordConfirmation
  }

  public func toInputDictionary() -> [String : Any] {
    return ["password": password,
            "passwordConfirmation": passwordConfirmation
    ]
  }
}
