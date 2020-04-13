import Foundation

extension SignInWithAppleEnvelope {
  public static let template = SignInWithAppleEnvelope(
    signInWithApple: SignInWithAppleEnvelope.SignInWithApple(
      apiAccessToken: "api_access_token",
      user: SignInWithAppleEnvelope.User(uid: "1")
    )
  )
}
