import KsApi
@testable import Library
import XCTest

final class FormatTests: TestCase {
  func testWholeNumber() {
    withEnvironment(locale: Locale(identifier: "en")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1,000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10,000")
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10.000")
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1 000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10 000")
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1.000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10.000")
    }

    withEnvironment(locale: Locale(identifier: "ja")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1,000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10,000")
    }
  }

  func testPercentages() {
    withEnvironment(locale: Locale(identifier: "en")) {
      XCTAssertEqual(Format.percentage(50), "50%")
      XCTAssertEqual(Format.percentage(1_000), "1,000%")
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1000 %")
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1 000 %")
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1.000 %")
    }

    withEnvironment(locale: Locale(identifier: "ja")) {
      XCTAssertEqual(Format.percentage(50), "50%")
      XCTAssertEqual(Format.percentage(1_000), "1,000%")
    }
  }

  func testPercentageFromDouble() {
    withEnvironment(locale: Locale(identifier: "en")) {
      XCTAssertEqual(Format.percentage(0.532), "53%")
      XCTAssertEqual(Format.percentage(10.66), "1,066%")
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1066 %")
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1 066 %")
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1.066 %")
    }

    withEnvironment(locale: Locale(identifier: "ja")) {
      XCTAssertEqual(Format.percentage(0.532), "53%")
      XCTAssertEqual(Format.percentage(10.66), "1,066%")
    }
  }

  func testDecimalCurrency() {
    XCTAssertEqual(Format.decimalCurrency(for: 10), "10.00")
    XCTAssertEqual(Format.decimalCurrency(for: 10.00), "10.00")
    XCTAssertEqual(Format.decimalCurrency(for: 10.50), "10.50")
    XCTAssertEqual(Format.decimalCurrency(for: 10.5555), "10.55", "Rounds down to 2 fraction digits")
    XCTAssertEqual(Format.decimalCurrency(for: 10.511), "10.51", "Rounds down to 2 fraction digits")
  }

  func testAttributedCurrency() {
    withEnvironment(locale: Locale(identifier: "en")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.us.currencyCode)?.string,
          "$1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.ca.currencyCode)?.string,
          " CA$ 1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.gb.currencyCode)?.string,
          "£1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.dk.currencyCode)?.string,
          " DKK 1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.de.currencyCode)?.string,
          "€1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.jp.currencyCode)?.string,
          "¥1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.gr.currencyCode)?.string,
          "€1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.si.currencyCode)?.string,
          "€1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(1_000, currencyCode: Project.Country.pl.currencyCode)?.string,
          "zł 1,000.00"
        )

        XCTAssertEqual(
          Format.attributedCurrency(
            1_000,
            currencyCode: Project.Country.ca.currencyCode,
            omitCurrencyCode: true
          )?.string, " CA$ 1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(
            1_000,
            currencyCode: Project.Country.ca.currencyCode,
            omitCurrencyCode: false
          )?.string, " CA$ 1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(
            1_000,
            currencyCode: Project.Country.us.currencyCode,
            omitCurrencyCode: true
          )?.string, "$1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(
            1_000,
            currencyCode: Project.Country.us.currencyCode,
            omitCurrencyCode: false
          )?.string, " US$ 1,000.00"
        )
        XCTAssertEqual(
          Format.attributedCurrency(
            1_000, currencyCode: Project.Country.us.currencyCode, omitCurrencyCode: true,
            maximumFractionDigits: 0, minimumFractionDigits: 0
          )?.string,
          "$1,000"
        )
        XCTAssertEqual(
          Format.attributedCurrency(
            1_000, currencyCode: Project.Country.us.currencyCode, omitCurrencyCode: false,
            maximumFractionDigits: 0, minimumFractionDigits: 0
          )?.string,
          " US$ 1,000"
        )
      }
    }
  }

  func testCurrency() {
    withEnvironment(locale: Locale(identifier: "en")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "$1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "CA$ 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "£1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "DKK 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "¥1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "zł 1,000")

        XCTAssertEqual(
          Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode, omitCurrencyCode: true),
          "CA$ 1,000"
        )
        XCTAssertEqual(
          Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode, omitCurrencyCode: false),
          "CA$ 1,000"
        )
        XCTAssertEqual(
          Format.currency(1_000, currencyCode: Project.Country.us.currencyCode, omitCurrencyCode: true),
          "$1,000"
        )
        XCTAssertEqual(
          Format.currency(1_000, currencyCode: Project.Country.us.currencyCode, omitCurrencyCode: false),
          "US$ 1,000"
        )
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "US$ 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "CA$ 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "£1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "DKK 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "¥1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "zł 1,000")

        XCTAssertEqual(
          Format.currency(1_000, currencyCode: Project.Country.us.currencyCode, omitCurrencyCode: true),
          "US$ 1,000"
        )
        XCTAssertEqual(
          Format.currency(1_000, currencyCode: Project.Country.us.currencyCode, omitCurrencyCode: false),
          "US$ 1,000"
        )
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "US$ 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "CA$ 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "£1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "DKK 1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "¥1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "€1,000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "zł 1,000")
      }
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1000 $")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1000 zł")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1000 zł")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1000 zł")
      }
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1 000 $")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1 000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1 000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1 000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1 000 zł")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1 000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1 000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1 000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1 000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1 000 zł")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1 000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1 000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1 000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1 000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1 000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1 000 zł")
      }
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1.000 $")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1.000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1.000 zł")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1.000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1.000 zł")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1.000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1.000 zł")
      }
    }

    withEnvironment(locale: Locale(identifier: "jp")) {
      withEnvironment(countryCode: "DK") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "US$ 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "CA$ 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "£ 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "DKK 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "€ 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "¥ 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "€ 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "€ 1000")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "zł 1000")
      }
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1.000 $")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1.000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1.000 zł")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1.000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1.000 zł")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.us.currencyCode), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.ca.currencyCode), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gb.currencyCode), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.dk.currencyCode), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.de.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.jp.currencyCode), "1.000 ¥")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.gr.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.si.currencyCode), "1.000 €")
        XCTAssertEqual(Format.currency(1_000, currencyCode: Project.Country.pl.currencyCode), "1.000 zł")
      }
    }
  }

  func testCurrencyMoneyFragment_USD() {
    withEnvironment(locale: Locale(identifier: "en_US")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.00", currency: .usd, symbol: "$")
      XCTAssertEqual(Format.currency(fragment), "$1,000.00")
    }
  }

  func testCurrencyMoneyFragment_USDCents() {
    withEnvironment(locale: Locale(identifier: "en_US")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.33", currency: .usd, symbol: "$")
      XCTAssertEqual(Format.currency(fragment), "$1,000.33")
    }
  }

  func testCurrencyMoneyFragment_USD_MoreThanTwoDecimals() {
    withEnvironment(locale: Locale(identifier: "en_US")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.987", currency: .usd, symbol: "$")
      XCTAssertEqual(Format.currency(fragment), "$1,000.99", "Should round to 2 decimal places")

      let fragmentRoundDown = GraphAPI.MoneyFragment(amount: "1000.994", currency: .usd, symbol: "$")
      XCTAssertEqual(Format.currency(fragmentRoundDown), "$1,000.99", "Should round down")

      let fragmentRoundUp = GraphAPI.MoneyFragment(amount: "1000.995", currency: .usd, symbol: "$")
      XCTAssertEqual(Format.currency(fragmentRoundUp), "$1,001.00", "Should round up")
    }
  }

  func testCurrencyMoneyFragment_EUR() {
    withEnvironment(locale: Locale(identifier: "de_DE")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.00", currency: .eur, symbol: "€")
      XCTAssertEqual(Format.currency(fragment), "1.000,00 €")
    }
  }

  func testCurrencyMoneyFragment_EUREurocents() {
    withEnvironment(locale: Locale(identifier: "de_DE")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.33", currency: .eur, symbol: "€")
      XCTAssertEqual(Format.currency(fragment), "1.000,33 €")
    }
  }

  func testCurrencyMoneyFragment_EuroInUS() {
    withEnvironment(locale: Locale(identifier: "en_US")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.00", currency: .eur, symbol: "€")
      XCTAssertEqual(Format.currency(fragment), "€1,000.00")
    }
  }

  func testCurrencyMoneyFragment_GBP() {
    withEnvironment(locale: Locale(identifier: "en_GB")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.00", currency: .gbp, symbol: "£")
      XCTAssertEqual(Format.currency(fragment), "£1,000.00")
    }
  }

  func testCurrencyMoneyFragment_GBPPence() {
    withEnvironment(locale: Locale(identifier: "en_GB")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.33", currency: .gbp, symbol: "£")
      XCTAssertEqual(Format.currency(fragment), "£1,000.33")
    }
  }

  func testCurrencyMoneyFragment_JPY() {
    withEnvironment(locale: Locale(identifier: "ja_JP")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.00", currency: .jpy, symbol: "¥")
      XCTAssertEqual(Format.currency(fragment), "¥1,000")
    }
  }

  func testCurrencyMoneyFragment_JPY_MoreThanTwoDecimals() {
    withEnvironment(locale: Locale(identifier: "ja_JP")) {
      let fragment = GraphAPI.MoneyFragment(amount: "1000.987", currency: .jpy, symbol: "¥")
      XCTAssertEqual(Format.currency(fragment), "¥1,001", "JPY should round to whole numbers")

      let fragmentRoundDown = GraphAPI.MoneyFragment(amount: "1000.499", currency: .jpy, symbol: "¥")
      XCTAssertEqual(Format.currency(fragmentRoundDown), "¥1,000", "Should round down")

      // for some reason the exact value of 1000.5 rounds down and not up
      let fragmentRoundUp = GraphAPI.MoneyFragment(amount: "1000.501", currency: .jpy, symbol: "¥")
      XCTAssertEqual(Format.currency(fragmentRoundUp), "¥1,001", "Should round up")
    }
  }

  func testCurrencyMoneyFragment_InvalidAmount() {
    let fragment = GraphAPI.MoneyFragment(amount: "invalid", currency: .usd, symbol: "$")
    XCTAssertNil(Format.currency(fragment))
  }

  func testCurrencyMoneyFragment_MissingSymbol() {
    let fragment = GraphAPI.MoneyFragment(amount: "1000.00", currency: nil, symbol: nil)
    XCTAssertNil(Format.currency(fragment))
  }

  func testCurrencyMoneyFragment_SmallAmount() {
    withEnvironment(locale: Locale(identifier: "en_US")) {
      let fragment = GraphAPI.MoneyFragment(amount: "10.50", currency: .usd, symbol: "$")
      XCTAssertEqual(Format.currency(fragment), "$10.50")
    }
  }

  func testCurrencyMoneyFragment_ZeroAmount() {
    withEnvironment(locale: Locale(identifier: "en_US")) {
      let fragment = GraphAPI.MoneyFragment(amount: "0.00", currency: .usd, symbol: "$")
      XCTAssertEqual(Format.currency(fragment), "$0.00")
    }
  }

  func testPlusSign() {
    withEnvironment(language: .de) {
      XCTAssertEqual(Format.attributedPlusSign().string, "+")
    }

    withEnvironment(language: .en) {
      XCTAssertEqual(Format.attributedPlusSign().string, "+")
    }

    withEnvironment(language: .es) {
      XCTAssertEqual(Format.attributedPlusSign().string, "+")
    }

    withEnvironment(language: .fr) {
      XCTAssertEqual(Format.attributedPlusSign().string, "+ ")
    }

    withEnvironment(language: .ja) {
      XCTAssertEqual(Format.attributedPlusSign().string, "+")
    }
  }

  func testPlusSignAttributes() {
    let expectedAttributes: String.Attributes = [
      .font: UIFont.ksr_body(),
      .foregroundColor: UIColor.red
    ]

    let attributedString = Format.attributedPlusSign(expectedAttributes)
    let attributes = attributedString.attributes(at: 0, effectiveRange: nil)

    XCTAssertEqual("+", attributedString.string)
    XCTAssertTrue(expectedAttributes == attributes)
  }

  func testDate() {
    let date = 434_592_000.0 // Oct 10 1983 in UTC
    let UTC = TimeZone(abbreviation: "UTC")!
    let EST = TimeZone(abbreviation: "EST")!
    var calUTC = Calendar.current
    calUTC.timeZone = UTC
    var calEST = Calendar.current
    calEST.timeZone = EST

    withEnvironment(locale: Locale(identifier: "en")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "Oct 10, 1983 at 12:00:00 AM")
      }

      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "Oct 9, 1983 at 8:00:00 PM")
      }
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "10.10.1983, 00:00:00")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "09.10.1983, 20:00:00")
      }
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "10 oct 1983, 0:00:00")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "9 oct 1983, 20:00:00")
      }
    }

    withEnvironment(locale: Locale(identifier: "ja")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "1983/10/10 0:00:00")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "1983/10/09 20:00:00")
      }
    }

    let ios10 = OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0)
    if ProcessInfo().isOperatingSystemAtLeast(ios10) {
      withEnvironment(locale: Locale(identifier: "fr")) {
        withEnvironment(calendar: calUTC) {
          XCTAssertEqual(Format.date(secondsInUTC: date), "10 oct. 1983 à 00:00:00")
        }
        withEnvironment(calendar: calEST) {
          XCTAssertEqual(Format.date(secondsInUTC: date), "9 oct. 1983 à 20:00:00")
        }
      }
    } else {
      withEnvironment(locale: Locale(identifier: "fr")) {
        withEnvironment(calendar: calUTC) {
          XCTAssertEqual(Format.date(secondsInUTC: date), "10 oct. 1983 00:00:00")
        }
        withEnvironment(calendar: calEST) {
          XCTAssertEqual(Format.date(secondsInUTC: date), "9 oct. 1983 20:00:00")
        }
      }
    }
  }

  func testDateWithDateFormat() {
    let date = 434_592_000.0 // Oct 10 1983 in UTC
    let UTC = TimeZone(abbreviation: "UTC")!
    let EST = TimeZone(abbreviation: "EST")!
    let format = "MMMyyyy"
    var calUTC = Calendar.current
    calUTC.timeZone = UTC
    var calEST = Calendar.current
    calEST.timeZone = EST

    withEnvironment(locale: Locale(identifier: "en")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "Oct 1983")
      }

      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "Oct 1983")
      }
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "Okt. 1983")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "Okt. 1983")
      }
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "oct 1983")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "oct 1983")
      }
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "oct. 1983")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "oct. 1983")
      }
    }

    withEnvironment(locale: Locale(identifier: "ja")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "1983年10月")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, template: format), "1983年10月")
      }
    }
  }

  func testDateFromString() {
    let format = "yyyy-MM"
    let dateString = "2018-01"
    let timeZone = UTCTimeZone
    let PST = TimeZone(abbreviation: "PST")
    let EST = TimeZone(abbreviation: "EST")!
    var calEST = Calendar.current
    calEST.timeZone = EST

    withEnvironment(calendar: calEST) {
      let date = Format.date(from: dateString, dateFormat: format, timeZone: timeZone)
      XCTAssertEqual(date?.description, "2018-01-01 00:00:00 +0000")
    }

    withEnvironment(calendar: calEST) {
      let date = Format.date(from: dateString, dateFormat: format)
      XCTAssertEqual(date?.description, "2018-01-01 05:00:00 +0000")
    }

    withEnvironment {
      let date = Format.date(from: dateString, dateFormat: format, timeZone: PST)
      XCTAssertEqual(date?.description, "2018-01-01 08:00:00 +0000")
    }

    // Test different format
    withEnvironment(calendar: calEST) {
      let date = Format.date(from: "2018-01-14", dateFormat: "yyyy-MM-dd")
      XCTAssertEqual(date?.description, "2018-01-14 05:00:00 +0000")
    }
  }

  func testDuration() {
    let now = self.dateType.init()
    let thirtyMins = now.timeIntervalSince1970 + 60 * 30
    let oneDay = now.timeIntervalSince1970 + 60 * 60 * 24
    let twoDays = now.timeIntervalSince1970 + 60 * 60 * 24 * 2
    let oneAndAHalfDays = now.timeIntervalSince1970 + 60 * 60 * 24 * 1.5
    let sixDays = now.timeIntervalSince1970 + 60 * 60 * 24 * 6
    let sixDaysPast = now.timeIntervalSince1970 - 60 * 60 * 24 * 6

    XCTAssertEqual("30", Format.duration(secondsInUTC: thirtyMins).time)
    XCTAssertEqual("minutes", Format.duration(secondsInUTC: thirtyMins).unit)

    XCTAssertEqual("24", Format.duration(secondsInUTC: oneDay).time)
    XCTAssertEqual("hours", Format.duration(secondsInUTC: oneDay).unit)

    XCTAssertEqual("36", Format.duration(secondsInUTC: oneAndAHalfDays).time)
    XCTAssertEqual("hours", Format.duration(secondsInUTC: oneAndAHalfDays).unit)

    XCTAssertEqual("6", Format.duration(secondsInUTC: sixDays).time)
    XCTAssertEqual("days", Format.duration(secondsInUTC: sixDays).unit)

    XCTAssertEqual("0", Format.duration(secondsInUTC: sixDaysPast).time)
    XCTAssertEqual("secs", Format.duration(secondsInUTC: sixDaysPast).unit)

    withEnvironment(language: .ja, locale: Locale(identifier: "ja"), mainBundle: MockBundle()) {
      XCTAssertEqual("2", Format.duration(secondsInUTC: twoDays).time)
      XCTAssertEqual("日", Format.duration(secondsInUTC: twoDays).unit)
    }
  }

  func testDurationAbbreviated() {
    let now = self.dateType.init()
    let thirtyMins = now.timeIntervalSince1970 + 60 * 30
    let oneDay = now.timeIntervalSince1970 + 60 * 60 * 24
    let oneAndAHalfDays = now.timeIntervalSince1970 + 60 * 60 * 24 * 1.5
    let sixDays = now.timeIntervalSince1970 + 60 * 60 * 24 * 6
    let sixDaysPast = now.timeIntervalSince1970 - 60 * 60 * 24 * 6

    XCTAssertEqual("30", Format.duration(secondsInUTC: thirtyMins, abbreviate: true).time)
    XCTAssertEqual("mins", Format.duration(secondsInUTC: thirtyMins, abbreviate: true).unit)

    XCTAssertEqual("24", Format.duration(secondsInUTC: oneDay, abbreviate: true).time)
    XCTAssertEqual("hrs", Format.duration(secondsInUTC: oneDay, abbreviate: true).unit)

    XCTAssertEqual("36", Format.duration(secondsInUTC: oneAndAHalfDays, abbreviate: true).time)
    XCTAssertEqual("hrs", Format.duration(secondsInUTC: oneAndAHalfDays, abbreviate: true).unit)

    XCTAssertEqual("6", Format.duration(secondsInUTC: sixDays, abbreviate: true).time)
    XCTAssertEqual("days", Format.duration(secondsInUTC: sixDays, abbreviate: true).unit)

    XCTAssertEqual("0", Format.duration(secondsInUTC: sixDaysPast, abbreviate: true).time)
    XCTAssertEqual("secs", Format.duration(secondsInUTC: sixDaysPast, abbreviate: true).unit)
  }

  func testDurationUsingToGo() {
    let now = self.dateType.init()
    let thirtyMins = now.timeIntervalSince1970 + 60 * 30
    let oneMinute = now.timeIntervalSince1970 + 60
    let oneDay = now.timeIntervalSince1970 + 60 * 60 * 24
    let oneAndAHalfDays = now.timeIntervalSince1970 + 60 * 60 * 24 * 1.5
    let sixDays = now.timeIntervalSince1970 + 60 * 60 * 24 * 6
    let sixDaysPast = now.timeIntervalSince1970 - 60 * 60 * 24 * 6

    XCTAssertEqual("30", Format.duration(secondsInUTC: thirtyMins, useToGo: true).time)
    XCTAssertEqual("minutes to go", Format.duration(secondsInUTC: thirtyMins, useToGo: true).unit)

    XCTAssertEqual("1", Format.duration(secondsInUTC: oneMinute, useToGo: true).time)
    XCTAssertEqual("minute to go", Format.duration(secondsInUTC: oneMinute, useToGo: true).unit)

    XCTAssertEqual("24", Format.duration(secondsInUTC: oneDay, useToGo: true).time)
    XCTAssertEqual("hours to go", Format.duration(secondsInUTC: oneDay, useToGo: true).unit)

    XCTAssertEqual("36", Format.duration(secondsInUTC: oneAndAHalfDays, useToGo: true).time)
    XCTAssertEqual("hours to go", Format.duration(secondsInUTC: oneAndAHalfDays, useToGo: true).unit)

    XCTAssertEqual("6", Format.duration(secondsInUTC: sixDays, useToGo: true).time)
    XCTAssertEqual("days to go", Format.duration(secondsInUTC: sixDays, useToGo: true).unit)

    XCTAssertEqual("0", Format.duration(secondsInUTC: sixDaysPast, useToGo: true).time)
    XCTAssertEqual("secs to go", Format.duration(secondsInUTC: sixDaysPast, useToGo: true).unit)
  }

  func testRelative() {
    let now = self.dateType.init()
    let justNow = now.timeIntervalSince1970 - 30
    let rightNow = now.timeIntervalSince1970 + 30
    let minutesAgo = now.timeIntervalSince1970 - (60 * 30)
    let inMinutes = now.timeIntervalSince1970 + (60 * 30)
    let hoursAgo = now.timeIntervalSince1970 - (60 * 60)
    let inHours = now.timeIntervalSince1970 + (60 * 60)
    let yesterday = now.timeIntervalSince1970 - (60 * 60 * 24)
    let tomorrow = now.timeIntervalSince1970 + (60 * 60 * 24)
    let daysAgo = now.timeIntervalSince1970 - (60 * 60 * 24 * 2)
    let inDays = now.timeIntervalSince1970 + (60 * 60 * 24 * 2)

    let muliplier = (60 * 60 * 24 * 30 + 60 * 60 * 24)
    let awhileAgo = now.timeIntervalSince1970 - TimeInterval(muliplier)
    let inAwhile = now.timeIntervalSince1970 + TimeInterval(muliplier)

    withEnvironment(language: .en, locale: Locale(identifier: "en"), mainBundle: MockBundle()) {
      XCTAssertEqual("just now", Format.relative(secondsInUTC: justNow))
      XCTAssertEqual("right now", Format.relative(secondsInUTC: rightNow))
      XCTAssertEqual("30 minutes ago", Format.relative(secondsInUTC: minutesAgo))
      XCTAssertEqual("in 30 minutes", Format.relative(secondsInUTC: inMinutes))
      XCTAssertEqual("1 hour ago", Format.relative(secondsInUTC: hoursAgo))
      XCTAssertEqual("in 1 hour", Format.relative(secondsInUTC: inHours))
      XCTAssertEqual("yesterday", Format.relative(secondsInUTC: yesterday))
      XCTAssertEqual("in 1 day", Format.relative(secondsInUTC: tomorrow))
      XCTAssertEqual("2 days ago", Format.relative(secondsInUTC: daysAgo))
      XCTAssertEqual("in 2 days", Format.relative(secondsInUTC: inDays))
      XCTAssertEqual(
        Format.date(secondsInUTC: awhileAgo, timeStyle: .none),
        Format.relative(secondsInUTC: awhileAgo)
      )
      XCTAssertEqual(
        Format.date(secondsInUTC: inAwhile, timeStyle: .none),
        Format.relative(secondsInUTC: inAwhile)
      )

      XCTAssertEqual("just now", Format.relative(secondsInUTC: justNow, abbreviate: true))
      XCTAssertEqual("right now", Format.relative(secondsInUTC: rightNow, abbreviate: true))
      XCTAssertEqual("30 mins ago", Format.relative(secondsInUTC: minutesAgo, abbreviate: true))
      XCTAssertEqual("in 30 mins", Format.relative(secondsInUTC: inMinutes, abbreviate: true))
      XCTAssertEqual("1 hr ago", Format.relative(secondsInUTC: hoursAgo, abbreviate: true))
      XCTAssertEqual("in 1 hr", Format.relative(secondsInUTC: inHours, abbreviate: true))
      XCTAssertEqual("yesterday", Format.relative(secondsInUTC: yesterday, abbreviate: true))
      XCTAssertEqual("in 1 day", Format.relative(secondsInUTC: tomorrow, abbreviate: true))
      XCTAssertEqual("2 days ago", Format.relative(secondsInUTC: daysAgo, abbreviate: true))
      XCTAssertEqual("in 2 days", Format.relative(secondsInUTC: inDays, abbreviate: true))
      XCTAssertEqual(
        Format.date(secondsInUTC: awhileAgo, timeStyle: .none),
        Format.relative(secondsInUTC: awhileAgo, abbreviate: true)
      )
      XCTAssertEqual(
        Format.date(secondsInUTC: inAwhile, timeStyle: .none),
        Format.relative(secondsInUTC: inAwhile, abbreviate: true)
      )
    }

    withEnvironment(language: .de, locale: Locale(identifier: "de"), mainBundle: MockBundle()) {
      XCTAssertEqual("vor 1 Stunde", Format.relative(secondsInUTC: hoursAgo))
      XCTAssertEqual("vor 1 Std", Format.relative(secondsInUTC: hoursAgo, abbreviate: true))
    }
  }
}
