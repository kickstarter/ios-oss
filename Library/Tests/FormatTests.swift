import XCTest
@testable import Library
import KsApi

// swiftlint:disable function_body_length
final class FormatTests: XCTestCase {

  func testWholeNumber() {
    withEnvironment(locale: NSLocale(localeIdentifier: "en")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1,000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10,000")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "es")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1.000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10.000")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "fr")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1 000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10 000")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "de")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1.000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10.000")
    }
  }

  func testPercentages() {

    withEnvironment(locale: NSLocale(localeIdentifier: "en")) {
      XCTAssertEqual(Format.percentage(50), "50%")
      XCTAssertEqual(Format.percentage(1_000), "1,000%")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "es")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1.000 %")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "fr")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1 000 %")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "de")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1.000 %")
    }
  }

  func testCurrency() {
    withEnvironment(locale: NSLocale(localeIdentifier: "en")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "$1,000")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "$1,000 CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "kr1,000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€1,000")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "$1,000 USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "$1,000 CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "kr1,000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€1,000")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "$1,000 USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "$1,000 CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "kr1,000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€1,000")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "es")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $ USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $ USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "fr")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1 000 $")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1 000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1 000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1 000 €")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1 000 $ USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1 000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1 000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1 000 €")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1 000 $ USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1 000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1 000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1 000 €")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "de")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $ USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $ USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 $ CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 kr DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "dk")) {
      withEnvironment(countryCode: "DK") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "$ 1000 USD")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "$ 1000 CAD")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£ 1000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "kr 1000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€ 1000")
      }
    }
  }

  func testDate() {
    let date = 434592000.0 // Oct 10 1983 in UTC
    let UTC = NSTimeZone(abbreviation: "UTC")!
    let EST = NSTimeZone(abbreviation: "EST")!

    withEnvironment(locale: NSLocale(localeIdentifier: "en")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "Oct 10, 1983, 12:00:00 AM")
      }

      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "Oct 9, 1983, 8:00:00 PM")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "de")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "10.10.1983, 00:00:00")
      }
      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "09.10.1983, 20:00:00")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "es")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "10 oct 1983 0:00:00")
      }
      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "9 oct 1983 20:00:00")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "fr")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "10 oct. 1983 00:00:00")
      }
      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "9 oct. 1983 20:00:00")
      }
    }
  }
}
