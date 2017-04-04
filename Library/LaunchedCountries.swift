import struct KsApi.Project

public struct LaunchedCountries {
  public let countries: [Project.Country]

  public init() {
    self.countries = [
      .AT, .AU, .BE, .CA, .CH, .DE, .DK, .ES, .FR, .GB, .HK, .IE, .IT, .LU, .MX, .NL, .NO, .NZ, .SE, .SG, .US
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
