import Argo
import Curry
@testable import KsApi
import Runes
import XCTest

final class ConfigTests: XCTestCase {
  let json: [String: Any] = [
    "ab_experiments": [
      "2001_space_odyssey": "control",
      "dr_strangelove": "experiment"
    ],
    "app_id": 123_456_789,
    "apple_pay_countries": ["US", "GB", "CA"],
    "country_code": "US",
    "features": [
      "feature1": true,
      "feature2": false
    ],
    "itunes_link": "http://www.itunes.com",
    "launched_countries": [
      [
        "trailing_code": false,
        "currency_symbol": "€",
        "currency_code": "EUR",
        "name": "ES"
      ],
      [
        "trailing_code": false,
        "currency_symbol": "€",
        "currency_code": "EUR",
        "name": "FR"
      ]
    ],
    "locale": "en",
    "stripe": [
      "publishable_key": "pk"
    ]
  ]

  func testSwiftDecoding() {
    let data = try? JSONSerialization.data(withJSONObject: self.json, options: [])

    if let data = data, let config = try? JSONDecoder().decode(Config.self, from: data) {
      self.assertValues(of: config)
    } else {
      XCTFail("Config should not be nil")
    }
  }

  func testDecoding() {
    // Confirm json decoded successfully
    let decodedConfig = Config.decodeJSONDictionary(self.json)
    XCTAssertNil(decodedConfig.error)

    let config = decodedConfig.value!
    self.assertValues(of: config)
  }

  private func assertValues(of config: Config) {
    XCTAssertEqual(["2001_space_odyssey": "control", "dr_strangelove": "experiment"], config.abExperiments)
    XCTAssertEqual(123_456_789, config.appId)
    XCTAssertEqual("US", config.countryCode)
    XCTAssertEqual(["US", "GB", "CA"], config.applePayCountries)
    XCTAssertEqual(["feature1": true, "feature2": false], config.features)
    XCTAssertEqual("http://www.itunes.com", config.iTunesLink)
    XCTAssertEqual([.es, .fr], config.launchedCountries)
    XCTAssertEqual("en", config.locale)
    XCTAssertEqual("pk", config.stripePublishableKey)
    XCTAssertTrue(config.abExperimentsArray.contains("2001_space_odyssey[control]") &&
      config.abExperimentsArray.contains("dr_strangelove[experiment]"))
    // Confirm that encoding and decoding again results in the same config.
    XCTAssertEqual(config, Config.decodeJSONDictionary(config.encode()).value)
  }
}
