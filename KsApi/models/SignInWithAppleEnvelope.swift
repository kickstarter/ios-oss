import Foundation

public struct SignInWithAppleEnvelope: Decodable {
  public var signInWithApple: SignInWithApple

  public struct SignInWithApple: Decodable {
    public var apiAccessToken: String
    public var user: SignInWithAppleEnvelope.User
  }

  public struct User: Decodable {
    public var uid: String
  }
}
