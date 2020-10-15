import Foundation

public struct SignInWithAppleEnvelope: Swift.Decodable {
  public var signInWithApple: SignInWithApple

  public struct SignInWithApple: Swift.Decodable {
    public var apiAccessToken: String
    public var user: SignInWithAppleEnvelope.User
  }

  public struct User: Swift.Decodable {
    public var uid: String
  }
}
