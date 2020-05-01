import Foundation

public struct ChangePasswordInput: GraphMutationInput {
  let currentPassword: String
  let newPassword: String
  let newPasswordConfirmation: String

  public init(currentPassword: String, newPassword: String, newPasswordConfirmation: String) {
    self.currentPassword = currentPassword
    self.newPassword = newPassword
    self.newPasswordConfirmation = newPasswordConfirmation
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "currentPassword": self.currentPassword,
      "password": self.newPassword,
      "passwordConfirmation": self.newPasswordConfirmation
    ]
  }
}
