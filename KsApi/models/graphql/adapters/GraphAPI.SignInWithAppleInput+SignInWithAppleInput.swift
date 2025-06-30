import Foundation

extension GraphAPI.SignInWithAppleInput {
  static func from(_ input: SignInWithAppleInput) -> GraphAPI.SignInWithAppleInput {
    return GraphAPI.SignInWithAppleInput(
      firstName: .someOrNil(input.firstName),
      lastName: .someOrNil(input.lastName),
      authCode: input.authCode,
      iosAppId: input.appId
    )
  }
}
