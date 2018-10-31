import Prelude

public struct UserCurrency: Swift.Decodable {
  public private(set) var chosenCurrency: String?
}

extension UserCurrency: Equatable {
}
