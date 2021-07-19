
import Foundation

extension GraphAPI.UpdateUserAccountInput {
  static func from(_ input: CreatePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(password: input.password,
                                           passwordConfirmation: input.passwordConfirmation)
  }
  
  static func from(_ input: ChangePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(currentPassword: input.currentPassword,
                                           password: input.newPassword,
                                           passwordConfirmation: input.newPasswordConfirmation)
  }
}
