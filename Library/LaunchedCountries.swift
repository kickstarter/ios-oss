import struct KsApi.Project

public struct LaunchedCountries {
  public let countries: [Project.Country]

  public init() {
    self.countries = [
      .US, .CA, .AU, .NZ, .GB, .NL, .IE, .DE, .ES,
      .FR, .IT, .AT, .BE, .LU, .SE, .DK, .NO, .CH
    ]
  }

  /**
   Determines if a currency needs to display it's country code when displaying amounts, e.g. $10 CAD.

   - parameter currencySymbol: A currency symbol.

   - returns: A boolean.
   */
  public func currencyNeedsCode(currencySymbol: String) -> Bool {
    for country in self.countries {
      if country.currencySymbol == currencySymbol {
        return country.trailingCode
      }
    }
    return false
  }
}
