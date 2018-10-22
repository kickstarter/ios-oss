import Prelude

public struct UserCurrency: Swift.Decodable {
  public let chosenCurrency: String?
}

extension UserCurrency: Equatable {
}
