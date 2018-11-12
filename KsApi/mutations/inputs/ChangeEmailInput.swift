import Foundation

public struct ChangeEmailInput: GraphMutationInput {
  let email: String
  let currentPassword: String

  public init(email: String, currentPassword: String) {
    self.currentPassword = currentPassword
    self.email = email
  }

  public func toInputDictionary() -> [String: Any] {
    return ["currentPassword": currentPassword,
            "email": email
    ]
  }
}
