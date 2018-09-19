import XCTest
@testable import KsApi
import Argo
import Curry
import Runes

final class ConfigTests: XCTestCase {

  func testDecoding() {

    let abExperiments = [
      "2001_space_odyssey": "control",
      "dr_strangelove": "experiment"
    ]

    let features = [
      "feature1": true,
      "feature2": false,
      ]
    let json: [String: Any] = [
      "ab_experiments": abExperiments,
      "app_id": 123456789,
      "apple_pay_countries": ["US", "GB", "CA"],
      "country_code": "US",
      "features": features,
      "itunes_link": "http://www.itunes.com",
      "launched_countries": [
        [ "trailing_code": false,
          "currency_symbol": "€",
          "currency_code": "EUR",
          "name": "ES" ],
        [
          "trailing_code": false,
          "currency_symbol": "€",
          "currency_code": "EUR",
          "name": "FR" ]
      ],
      "locale": "en",
      "stripe": [
        "publishable_key": "pk"
      ]
    ]

    // Confirm json decoded successfully
    let decodedConfig = Config.decodeJSONDictionary(json)
    XCTAssertNil(decodedConfig.error)

    // Confirm fields decoded properly
    // swiftlint:disable:next force_unwrapping
    let config = decodedConfig.value!
    XCTAssertEqual(abExperiments, config.abExperiments)
    XCTAssertEqual(123456789, config.appId)
    XCTAssertEqual("US", config.countryCode)
    XCTAssertEqual(["US", "GB", "CA"], config.applePayCountries)
    XCTAssertEqual(features, config.features)
    XCTAssertEqual("http://www.itunes.com", config.iTunesLink)
    XCTAssertEqual([.es, .fr], config.launchedCountries)
    XCTAssertEqual("en", config.locale)
    XCTAssertEqual("pk", config.stripePublishableKey)
    XCTAssertEqual(["2001_space_odyssey[control]", "dr_strangelove[experiment]"], config.abExperimentsArray)
    // Confirm that encoding and decoding again results in the same config.
    XCTAssertEqual(config, Config.decodeJSONDictionary(config.encode()).value)
  }
}
