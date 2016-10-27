import XCTest
import KsApi
@testable import Library

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

  func testPercentageFromDouble() {
    withEnvironment(locale: NSLocale(localeIdentifier: "en")) {
      XCTAssertEqual(Format.percentage(0.532), "53%")
      XCTAssertEqual(Format.percentage(10.66), "1,066%")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "es")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1.066 %")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "fr")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1 066 %")
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "de")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1.066 %")
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

        XCTAssertEqual(Format.currency(1_000, country: .CA, omitCurrencyCode: true), "$1,000")
        XCTAssertEqual(Format.currency(1_000, country: .CA, omitCurrencyCode: false), "$1,000 CAD")
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

    let ios10 = NSOperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0)
    if NSProcessInfo().isOperatingSystemAtLeastVersion(ios10) {
      withEnvironment(locale: NSLocale(localeIdentifier: "fr")) {
        withEnvironment(timeZone: UTC) {
          XCTAssertEqual(Format.date(secondsInUTC: date), "10 oct. 1983 à 00:00:00")
        }
        withEnvironment(timeZone: EST) {
          XCTAssertEqual(Format.date(secondsInUTC: date), "9 oct. 1983 à 20:00:00")
        }
      }
    } else {
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

  func testDateWithDateFormat() {
    let date = 434592000.0 // Oct 10 1983 in UTC
    let UTC = NSTimeZone(abbreviation: "UTC")!
    let EST = NSTimeZone(abbreviation: "EST")!
    let format = "MMM yyyy"

    withEnvironment(locale: NSLocale(localeIdentifier: "en")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Oct 1983")
      }

      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Oct 1983")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "de")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Okt. 1983")
      }
      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Okt. 1983")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "es")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct 1983")
      }
      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct 1983")
      }
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "fr")) {
      withEnvironment(timeZone: UTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct. 1983")
      }
      withEnvironment(timeZone: EST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct. 1983")
      }
    }
  }

  func testDuration() {
    let thirtyMins = NSDate().timeIntervalSince1970 + 60 * 30 + 1
    let oneDay = NSDate().timeIntervalSince1970 + 60 * 60 * 24 + 1
    let oneAndAHalfDays = NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 1.5 + 1
    let sixDays = NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 6 + 1
    let sixDaysPast = NSDate().timeIntervalSince1970 - 60 * 60 * 24 * 6 + 1

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
  }

  func testDurationAbbreviated() {
    let thirtyMins = NSDate().timeIntervalSince1970 + 60 * 30 + 1
    let oneDay = NSDate().timeIntervalSince1970 + 60 * 60 * 24 + 1
    let oneAndAHalfDays = NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 1.5 + 1
    let sixDays = NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 6 + 1
    let sixDaysPast = NSDate().timeIntervalSince1970 - 60 * 60 * 24 * 6 + 1

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
    let thirtyMins = NSDate().timeIntervalSince1970 + 60 * 30 + 1
    let oneAndAHalfDays = NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 1.5 + 1
    let oneDay = NSDate().timeIntervalSince1970 + 60 * 60 * 24 + 1
    let oneMinute = NSDate().timeIntervalSince1970 + 60 + 1
    let sixDays = NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 6 + 1
    let sixDaysPast = NSDate().timeIntervalSince1970 - 60 * 60 * 24 * 6 + 1

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
    let justNow = NSDate().timeIntervalSince1970 - 30
    let rightNow = NSDate().timeIntervalSince1970 + 31
    let minutesAgo = NSDate().timeIntervalSince1970 - 60 * 30
    let inMinutes = NSDate().timeIntervalSince1970 + 60 * 31
    let hoursAgo = NSDate().timeIntervalSince1970 - 60 * 60
    let inHours = NSDate().timeIntervalSince1970 + 60 * 61
    let yesterday = NSDate().timeIntervalSince1970 - 60 * 60 * 24
    let tomorrow = NSDate().timeIntervalSince1970 + 60 * 61 * 24
    let daysAgo = NSDate().timeIntervalSince1970 - 60 * 60 * 24 * 2
    let inDays = NSDate().timeIntervalSince1970 + 60 * 61 * 24 * 2
    let awhileAgo = NSDate().timeIntervalSince1970 - 60 * 60 * 24 * 31
    let inAwhile = NSDate().timeIntervalSince1970 - 60 * 60 * 24 * 32

    withEnvironment(locale: NSLocale(localeIdentifier: "en"), language: .en, mainBundle: MockBundle()) {
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
      XCTAssertEqual(Format.date(secondsInUTC: awhileAgo, timeStyle: .NoStyle),
                     Format.relative(secondsInUTC: awhileAgo))
      XCTAssertEqual(Format.date(secondsInUTC: inAwhile, timeStyle: .NoStyle),
                     Format.relative(secondsInUTC: inAwhile))

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
      XCTAssertEqual(Format.date(secondsInUTC: awhileAgo, timeStyle: .NoStyle),
                     Format.relative(secondsInUTC: awhileAgo, abbreviate: true))
      XCTAssertEqual(Format.date(secondsInUTC: inAwhile, timeStyle: .NoStyle),
                     Format.relative(secondsInUTC: inAwhile, abbreviate: true))
    }

    withEnvironment(locale: NSLocale(localeIdentifier: "de"), language: .de, mainBundle: MockBundle()) {
      XCTAssertEqual("vor 1 Stunde", Format.relative(secondsInUTC: hoursAgo))
      XCTAssertEqual("vor 1 Std", Format.relative(secondsInUTC: hoursAgo, abbreviate: true))
    }
  }
}
