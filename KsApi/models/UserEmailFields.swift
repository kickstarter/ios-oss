import Foundation

public struct UserEmailFields: Swift.Decodable {
  public var email: String
  public var isEmailVerified: Bool?
  public var isDeliverable: Bool?
}
