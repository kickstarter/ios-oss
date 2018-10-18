import Prelude

public struct UserCurrency: Swift.Decodable {
  public let chosenCurrency: String?
}

extension UserCurrency: Equatable {
}

extension UserCurrency {
  internal static let template = UserCurrency(
    chosenCurrency: "USD"
  )
}

extension UserCurrency {
  public enum lens {
    public static let chosenCurrency = Lens<UserCurrency, String?>(
      view: { $0.chosenCurrency },
      set: { part, _ in UserCurrency(chosenCurrency: part) }
    )
  }
}
