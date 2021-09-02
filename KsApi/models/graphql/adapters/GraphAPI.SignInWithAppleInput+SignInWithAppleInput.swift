import Foundation

extension GraphAPI.SignInWithAppleInput {
  static func from(_ input: SignInWithAppleInput) -> GraphAPI.SignInWithAppleInput {
    return GraphAPI.SignInWithAppleInput(
      firstName: input.firstName,
      lastName: input.lastName,
      authCode: input.authCode,
      iosAppId: input.appId
    )
  }
}
