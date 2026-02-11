import Foundation
import GraphAPI

extension GraphAPI.UpdateUserAccountInput {
  /**
   Maps a `CreatePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: CreatePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      password: GraphQLNullable.someOrNil(input.password),
      passwordConfirmation: GraphQLNullable.someOrNil(input.passwordConfirmation)
    )
  }

  /**
   Maps a `ChangePasswordInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangePasswordInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: GraphQLNullable.someOrNil(input.currentPassword),
      password: GraphQLNullable.someOrNil(input.newPassword),
      passwordConfirmation: GraphQLNullable.someOrNil(input.newPasswordConfirmation)
    )
  }

  /**
   Maps a `ChangeEmailInput` to a `GraphAPI.UpdateUserAccountInput`
   */
  static func from(_ input: ChangeEmailInput) -> GraphAPI.UpdateUserAccountInput {
    return GraphAPI.UpdateUserAccountInput(
      currentPassword: GraphQLNullable.someOrNil(input.currentPassword),
      email: GraphQLNullable.someOrNil(input.email)
    )
  }
}
