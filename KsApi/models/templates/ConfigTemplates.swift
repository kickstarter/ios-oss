import Prelude

extension Config {
  internal static let template = Config(
    abExperiments: [:],
    appId: 123456789,
    applePayCountries: ["US", "GB", "CA", "AU", "FR", "CH", "SG", "HK", "ES", "NZ"],
    countryCode: "US",
    features: [:],
    iTunesLink: "http://www.itunes.com",
    launchedCountries: [.us, .ca, .au, .nz, .gb, .nl, .ie, .de, .es, .fr, .it, .at, .be, .lu, .se, .dk, .no,
      .ch, .hk, .sg],
    locale: "en",
    stripePublishableKey: "pk"
  )

  internal static let config = Config.template

  internal static let deConfig = Config.template
    |> Config.lens.countryCode .~ "DE"
    |> Config.lens.locale .~ "de"
}
