import XCTest
import KsApi
@testable import Library

// swiftlint:disable function_body_length
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
      XCTAssertEqual(Format.wholeNumber(1_000), "1.000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10.000")
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1 000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10 000")
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertEqual(Format.wholeNumber(10), "10")
      XCTAssertEqual(Format.wholeNumber(100), "100")
      XCTAssertEqual(Format.wholeNumber(1_000), "1.000")
      XCTAssertEqual(Format.wholeNumber(10_000), "10.000")
    }
  }

  func testPercentages() {

    withEnvironment(locale: Locale(identifier: "en")) {
      XCTAssertEqual(Format.percentage(50), "50%")
      XCTAssertEqual(Format.percentage(1_000), "1,000%")
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1.000 %")
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1 000 %")
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertEqual(Format.percentage(50), "50 %")
      XCTAssertEqual(Format.percentage(1_000), "1.000 %")
    }
  }

  func testPercentageFromDouble() {
    withEnvironment(locale: Locale(identifier: "en")) {
      XCTAssertEqual(Format.percentage(0.532), "53%")
      XCTAssertEqual(Format.percentage(10.66), "1,066%")
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1.066 %")
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1 066 %")
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertEqual(Format.percentage(0.532), "53 %")
      XCTAssertEqual(Format.percentage(10.66), "1.066 %")
    }
  }

  func testCurrency() {
    withEnvironment(locale: Locale(identifier: "en")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "$1,000")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "CA$ 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "DKK 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€1,000")

        XCTAssertEqual(Format.currency(1_000, country: .CA, omitCurrencyCode: true), "CA$ 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .CA, omitCurrencyCode: false), "CA$ 1,000")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "US$ 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "CA$ 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "DKK 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€1,000")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "US$ 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "CA$ 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "DKK 1,000")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€1,000")
      }
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1 000 $")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1 000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1 000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1 000 €")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1 000 US$")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1 000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1 000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1 000 €")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1 000 US$")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1 000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1 000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1 000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1 000 €")
      }
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      withEnvironment(countryCode: "US") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 $")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "CA") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }

      withEnvironment(countryCode: "GB") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "1.000 US$")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "1.000 CA$")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "1.000 £")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "1.000 DKK")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "1.000 €")
      }
    }

    withEnvironment(locale: Locale(identifier: "dk")) {
      withEnvironment(countryCode: "DK") {
        XCTAssertEqual(Format.currency(1_000, country: .US), "US$ 1000")
        XCTAssertEqual(Format.currency(1_000, country: .CA), "CA$ 1000")
        XCTAssertEqual(Format.currency(1_000, country: .GB), "£ 1000")
        XCTAssertEqual(Format.currency(1_000, country: .DK), "DKK 1000")
        XCTAssertEqual(Format.currency(1_000, country: .DE), "€ 1000")
      }
    }
  }

  func testDate() {
    let date = 434592000.0 // Oct 10 1983 in UTC
    let UTC = TimeZone(abbreviation: "UTC")!
    let EST = TimeZone(abbreviation: "EST")!
    var calUTC = Calendar.current
    calUTC.timeZone = UTC
    var calEST = Calendar.current
    calEST.timeZone = EST

    withEnvironment(locale: Locale(identifier: "en")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "Oct 10, 1983, 12:00:00 AM")
      }

      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "Oct 9, 1983, 8:00:00 PM")
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
        XCTAssertEqual(Format.date(secondsInUTC: date), "10 oct 1983 0:00:00")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date), "9 oct 1983 20:00:00")
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
    let date = 434592000.0 // Oct 10 1983 in UTC
    let UTC = TimeZone(abbreviation: "UTC")!
    let EST = TimeZone(abbreviation: "EST")!
    let format = "MMM yyyy"
    var calUTC = Calendar.current
    calUTC.timeZone = UTC
    var calEST = Calendar.current
    calEST.timeZone = EST

    withEnvironment(locale: Locale(identifier: "en")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Oct 1983")
      }

      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Oct 1983")
      }
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Okt. 1983")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "Okt. 1983")
      }
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct 1983")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct 1983")
      }
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      withEnvironment(calendar: calUTC) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct. 1983")
      }
      withEnvironment(calendar: calEST) {
        XCTAssertEqual(Format.date(secondsInUTC: date, dateFormat: format), "oct. 1983")
      }
    }
  }

  func testDuration() {
    let now = self.dateType.init()
    let thirtyMins = now.timeIntervalSince1970 + 60 * 30
    let oneDay = now.timeIntervalSince1970 + 60 * 60 * 24
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
    let awhileAgo = now.timeIntervalSince1970 - (60 * 60 * 24 * 30 + 60 * 60 * 24)
    let inAwhile = now.timeIntervalSince1970 + (60 * 60 * 24 * 30 + 60 * 60 * 24)

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
      XCTAssertEqual(Format.date(secondsInUTC: awhileAgo, timeStyle: .none),
                     Format.relative(secondsInUTC: awhileAgo))
      XCTAssertEqual(Format.date(secondsInUTC: inAwhile, timeStyle: .none),
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
      XCTAssertEqual(Format.date(secondsInUTC: awhileAgo, timeStyle: .none),
                     Format.relative(secondsInUTC: awhileAgo, abbreviate: true))
      XCTAssertEqual(Format.date(secondsInUTC: inAwhile, timeStyle: .none),
                     Format.relative(secondsInUTC: inAwhile, abbreviate: true))
    }

    withEnvironment(language: .de, locale: Locale(identifier: "de"), mainBundle: MockBundle()) {
      XCTAssertEqual("vor 1 Stunde", Format.relative(secondsInUTC: hoursAgo))
      XCTAssertEqual("vor 1 Std", Format.relative(secondsInUTC: hoursAgo, abbreviate: true))
    }
  }
}
