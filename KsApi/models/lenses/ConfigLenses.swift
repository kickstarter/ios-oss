import Prelude

extension Config {
  public enum lens {
    public static let applePayCountries = Lens<Config, [String]>(
      view: { $0.applePayCountries },
      set: { Config(abExperiments: $1.abExperiments, appId: $1.appId, applePayCountries: $0,
        countryCode: $1.countryCode, features: $1.features, iTunesLink: $1.iTunesLink,
        launchedCountries: $1.launchedCountries, locale: $1.locale,
        stripePublishableKey: $1.stripePublishableKey) }
    )

    public static let countryCode = Lens<Config, String>(
      view: { $0.countryCode },
      set: { Config(abExperiments: $1.abExperiments, appId: $1.appId, applePayCountries: $1.applePayCountries,
                    countryCode: $0, features: $1.features, iTunesLink: $1.iTunesLink,
                    launchedCountries: $1.launchedCountries, locale: $1.locale,
                    stripePublishableKey: $1.stripePublishableKey) }
    )

    public static let features = Lens<Config, [String: Bool]>(
      view: { $0.features },
      set: { Config(abExperiments: $1.abExperiments, appId: $1.appId, applePayCountries: $1.applePayCountries,
                    countryCode: $1.countryCode, features: $0, iTunesLink: $1.iTunesLink,
                    launchedCountries: $1.launchedCountries, locale: $1.locale,
                    stripePublishableKey: $1.stripePublishableKey) }
    )

    public static let launchedCountries = Lens<Config, [Project.Country]>(
      view: { $0.launchedCountries },
      set: { Config(abExperiments: $1.abExperiments, appId: $1.appId, applePayCountries: $1.applePayCountries,
        countryCode: $1.countryCode, features: $1.features, iTunesLink: $1.iTunesLink, launchedCountries: $0,
        locale: $1.locale, stripePublishableKey: $1.stripePublishableKey) }
    )

    public static let locale = Lens<Config, String>(
      view: { $0.locale },
      set: { Config(abExperiments: $1.abExperiments, appId: $1.appId, applePayCountries: $1.applePayCountries,
        countryCode: $1.countryCode, features: $1.features, iTunesLink: $1.iTunesLink,
        launchedCountries: $1.launchedCountries, locale: $0, stripePublishableKey: $1.stripePublishableKey) }
    )

    public static let stripePublishableKey = Lens<Config, String>(
      view: { $0.stripePublishableKey },
      set: { Config(abExperiments: $1.abExperiments, appId: $1.appId, applePayCountries: $1.applePayCountries,
        countryCode: $1.countryCode, features: $1.features, iTunesLink: $1.iTunesLink,
        launchedCountries: $1.launchedCountries, locale: $1.locale, stripePublishableKey: $0) }
    )
  }
}
