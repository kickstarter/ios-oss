
import Foundation

extension GraphAPI.UpdateUserAccountInput {
  /**
   Maps a `CreatePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: CreatePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      password: .someOrNil(input.password),
      passwordConfirmation: .someOrNil(input.passwordConfirmation)
    )
  }

  /**
   Maps a `ChangePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: .someOrNil(input.currentPassword),
      password: .someOrNil(input.newPassword),
      passwordConfirmation: .someOrNil(input.newPasswordConfirmation)
    )
  }

  /**
   Maps a `ChangeEmailInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangeEmailInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: .someOrNil(input.currentPassword),
      email: .someOrNil(input.email)
    )
  }
}
