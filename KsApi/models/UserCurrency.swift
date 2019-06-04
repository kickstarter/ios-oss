import Prelude

public struct UserAccountFields: Swift.Decodable {
  public var chosenCurrency: String?
  public var email: String?
  public var hasPassword: Bool?
  public var isEmailVerified: Bool?
  public var isDeliverable: Bool?
}

extension UserAccountFields: Equatable {}
