import Prelude

extension Project.Country {
  static func country(from countryFragment: GraphAPI.CountryFragment,
                      minPledge: Int,
                      maxPledge: Int,
                      currency: GraphAPI.CurrencyCode) -> Project.Country? {
    guard let countryWithCurrencyDefault = Project.Country.all
      .first(where: { $0.countryCode == countryFragment.code.rawValue }) else {
      return nil
    }

    var updatedCountryWithProjectCurrency = countryWithCurrencyDefault
      |> Project.Country.lens.minPledge .~ minPledge
      |> Project.Country.lens.maxPledge .~ maxPledge
      |> Project.Country.lens.currencyCode .~ currency.rawValue

    if let matchingCurrencySymbol = Project.Country.all
      .first(where: { $0.currencyCode.lowercased() == currency.rawValue.lowercased() })?.currencySymbol {
      updatedCountryWithProjectCurrency = updatedCountryWithProjectCurrency
        |> Project.Country.lens.currencySymbol .~ matchingCurrencySymbol
    }

    return updatedCountryWithProjectCurrency
  }
}
