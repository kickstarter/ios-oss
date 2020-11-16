import Foundation

public struct UserEmailFields: Decodable {
  public var email: String
  public var isEmailVerified: Bool?
  public var isDeliverable: Bool?
}
