import Foundation

public struct UserEmailFields: Swift.Decodable {
  public let email: String
  public let isEmailVerified: Bool?
}
