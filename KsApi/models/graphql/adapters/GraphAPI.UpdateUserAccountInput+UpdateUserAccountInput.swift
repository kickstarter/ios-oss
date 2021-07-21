
import Foundation

extension GraphAPI.UpdateUserAccountInput {
  /**
   Maps a `CreatePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: CreatePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      password: input.password,
      passwordConfirmation: input.passwordConfirmation
    )
  }

  /**
   Maps a `ChangePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: input.currentPassword,
      password: input.newPassword,
      passwordConfirmation: input.newPasswordConfirmation
    )
  }

  /**
   Maps a `ChangeEmailInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangeEmailInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: input.currentPassword,
      email: input.email
    )
  }
}
