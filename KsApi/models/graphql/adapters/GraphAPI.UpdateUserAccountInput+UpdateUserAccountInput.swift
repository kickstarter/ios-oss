
import Foundation

extension GraphAPI.UpdateUserAccountInput {
  /**
   Maps a `CreatePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: CreatePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      password: GraphQLInput.someOrNil(input.password),
      passwordConfirmation: GraphQLInput.someOrNil(input.passwordConfirmation)
    )
  }

  /**
   Maps a `ChangePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: GraphQLInput.someOrNil(input.currentPassword),
      password: GraphQLInput.someOrNil(input.newPassword),
      passwordConfirmation: GraphQLInput.someOrNil(input.newPasswordConfirmation)
    )
  }

  /**
   Maps a `ChangeEmailInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangeEmailInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: GraphQLInput.someOrNil(input.currentPassword),
      email: GraphQLInput.someOrNil(input.email)
    )
  }
}
