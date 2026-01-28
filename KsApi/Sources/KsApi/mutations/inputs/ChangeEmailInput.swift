import Foundation

public struct ChangeEmailInput: GraphMutationInput {
  public let email: String
  public let currentPassword: String

  public init(email: String, currentPassword: String) {
    self.currentPassword = currentPassword
    self.email = email
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "currentPassword": self.currentPassword,
      "email": self.email
    ]
  }
}
