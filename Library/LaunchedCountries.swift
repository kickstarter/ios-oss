import struct KsApi.Project

public struct LaunchedCountries {
  public let countries: [Project.Country]

  public init() {
    self.countries = [
      .au, .at, .be, .ca, .ch, .de, .dk, .es, .fr, .gb, .hk, .ie, .it, .jp, .lu, .mx, .nl, .no, .nz, .se, .sg,
      .us
    ]
  }

  /**
   Determines if a currency needs to display it's country code when displaying amounts, e.g. $10 CAD.

   - parameter currencySymbol: A currency symbol.

   - returns: A boolean.
   */
  public func currencyNeedsCode(_ currencySymbol: String) -> Bool {
    for country in self.countries where country.currencySymbol == currencySymbol {
      return country.trailingCode
    }
    return false
  }
}
