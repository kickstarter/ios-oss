import GraphAPI
import Prelude

extension Project.Country {
  static func country(
    from countryFragment: GraphAPI.CountryFragment,
    minPledge: Int,
    maxPledge: Int,
    currency: GraphAPI.CurrencyCode?
  ) -> Project.Country? {
    guard let countryWithCurrencyDefault = Project.Country.all
      .first(where: { $0.countryCode == countryFragment.code.rawValue }) else {
      return nil
    }

    guard let currency else {
      return nil
    }

    var updatedCountryWithProjectCurrency = countryWithCurrencyDefault
    updatedCountryWithProjectCurrency.minPledge = minPledge
    updatedCountryWithProjectCurrency.maxPledge = maxPledge
    updatedCountryWithProjectCurrency.currencyCode = currency.rawValue

    if let matchingCurrencySymbol = Project.Country.all
      .first(where: { $0.currencyCode.lowercased() == currency.rawValue.lowercased() })?.currencySymbol {
      updatedCountryWithProjectCurrency.currencySymbol = matchingCurrencySymbol
    }

    return updatedCountryWithProjectCurrency
  }
}
