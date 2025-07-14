import Foundation
import GraphAPI

extension GraphAPI.SignInWithAppleInput {
  static func from(_ input: SignInWithAppleInput) -> GraphAPI.SignInWithAppleInput {
    return GraphAPI.SignInWithAppleInput(
      firstName: GraphQLNullable.someOrNil(input.firstName),
      lastName: GraphQLNullable.someOrNil(input.lastName),
      authCode: input.authCode,
      iosAppId: input.appId
    )
  }
}
