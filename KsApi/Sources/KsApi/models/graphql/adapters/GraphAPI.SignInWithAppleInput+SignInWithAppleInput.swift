import Foundation
import GraphAPI

extension GraphAPI.SignInWithAppleInput {
  static func from(_ input: SignInWithAppleInput) -> GraphAPI.SignInWithAppleInput {
    return GraphAPI.SignInWithAppleInput(
      authCode: input.authCode,
      firstName: GraphQLNullable.someOrNil(input.firstName),
      iosAppId: input.appId,
      lastName: GraphQLNullable.someOrNil(input.lastName)
    )
  }
}
