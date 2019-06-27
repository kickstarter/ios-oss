import Prelude

extension Project.Country {
  public enum lens {
    public static let maxPledge = Lens<Project.Country, Int?>(
      view: { $0.maxPledge },
      set: { Project.Country(
        countryCode: $1.countryCode,
        currencyCode: $1.currencyCode,
        currencySymbol: $1.currencySymbol,
        maxPledge: $0,
        minPledge: $1.minPledge,
        trailingCode: $1.trailingCode
      ) }
    )

    public static let minPledge = Lens<Project.Country, Int?>(
      view: { $0.minPledge },
      set: { Project.Country(
        countryCode: $1.countryCode,
        currencyCode: $1.currencyCode,
        currencySymbol: $1.currencySymbol,
        maxPledge: $1.maxPledge,
        minPledge: $0,
        trailingCode: $1.trailingCode
      ) }
    )
  }
}
