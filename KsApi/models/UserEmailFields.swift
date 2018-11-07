import Foundation

public struct UserEmailFields: Swift.Decodable {
  public private(set) var email: String
  public private(set) var isEmailVerified: Bool?
  public private(set) var isDeliverable: Bool?
}
