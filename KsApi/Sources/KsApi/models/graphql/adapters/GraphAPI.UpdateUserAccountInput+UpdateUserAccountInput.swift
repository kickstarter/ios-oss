import Foundation
import GraphAPI

extension GraphAPI.UpdateUserAccountInput {
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
