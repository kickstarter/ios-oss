
import Foundation

extension GraphAPI.UpdateUserAccountInput {
  static func from(_ input: CreatePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(password: input.password, passwordConfirmation: input.passwordConfirmation)
  }
}
