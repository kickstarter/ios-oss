import Prelude

public struct UserAccountFields: Swift.Decodable {
  public private(set) var chosenCurrency: String?
  public private(set) var isEmailVerified: Bool?
  public private(set) var isDeliverable: Bool?
}

extension UserAccountFields: Equatable {}
