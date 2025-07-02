import Foundation

extension GraphAPI.SignInWithAppleInput {
  static func from(_ input: SignInWithAppleInput) -> GraphAPI.SignInWithAppleInput {
    return GraphAPI.SignInWithAppleInput(
      firstName: GraphQLInput.someOrNil(input.firstName),
      lastName: GraphQLInput.someOrNil(input.lastName),
      authCode: input.authCode,
      iosAppId: input.appId
    )
  }
}
