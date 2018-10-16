public struct UserCurrency: Swift.Decodable {
  public let chosenCurrency: String?
}

extension UserCurrency {
  internal static let template = UserCurrency(chosenCurrency: "USD")
}
