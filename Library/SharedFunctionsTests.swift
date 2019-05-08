import Foundation
import ReactiveSwift
import Result
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import XCTest

final class SharedFunctionsTests: TestCase {

  func testCountdownProducer() {
    let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 2
    let futureDate = MockDate().addingTimeInterval(future).date
    let countdown = countdownProducer(to: futureDate)

    let dayTest = TestObserver<String, NoError>()
    let hourTest = TestObserver<String, NoError>()
    let minuteTest = TestObserver<String, NoError>()
    let secondTest = TestObserver<String, NoError>()

    countdown.map { $0.day }.start(dayTest.observer)
    countdown.map { $0.hour }.start(hourTest.observer)
    countdown.map { $0.minute }.start(minuteTest.observer)
    countdown.map { $0.second }.start(secondTest.observer)

    dayTest.assertValues(["01"])
    hourTest.assertValues(["16"])
    minuteTest.assertValues(["34"])
    secondTest.assertValues(["02"])

    self.scheduler.advance(by: .seconds(1))

    dayTest.assertValues(["01", "01"])
    hourTest.assertValues(["16", "16"])
    minuteTest.assertValues(["34", "34"])
    secondTest.assertValues(["02", "01"])

    self.scheduler.advance(by: .seconds(1))

    dayTest.assertValues(["01", "01", "01"])
    hourTest.assertValues(["16", "16", "16"])
    minuteTest.assertValues(["34", "34", "34"])
    secondTest.assertValues(["02", "01", "00"])

    self.scheduler.advance(by: .seconds(1))

    dayTest.assertValues(["01", "01", "01", "01"])
    hourTest.assertValues(["16", "16", "16", "16"])
    minuteTest.assertValues(["34", "34", "34", "33"])
    secondTest.assertValues(["02", "01", "00", "59"])
  }

  func testCountdownProducer_FractionalStartSecond() {

    let fractionalSecondScheduler = TestScheduler(startDate: MockDate().addingTimeInterval(-0.5).date)

    withEnvironment(scheduler: fractionalSecondScheduler) {

      let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 2
      let futureDate = MockDate().addingTimeInterval(future).date
      let countdown = countdownProducer(to: futureDate)

      let dayTest = TestObserver<String, NoError>()
      let hourTest = TestObserver<String, NoError>()
      let minuteTest = TestObserver<String, NoError>()
      let secondTest = TestObserver<String, NoError>()

      countdown.map { $0.day }.start(dayTest.observer)
      countdown.map { $0.hour }.start(hourTest.observer)
      countdown.map { $0.minute }.start(minuteTest.observer)
      countdown.map { $0.second }.start(secondTest.observer)

      // Inital countdown is emitted immediately
      dayTest.assertValues(["01"])
      hourTest.assertValues(["16"])
      minuteTest.assertValues(["34"])
      secondTest.assertValues(["02"])

      fractionalSecondScheduler.advance(by: .seconds(1))

      // Waiting a second does not emit again because we have an additional half second to account for
      dayTest.assertValues(["01"])
      hourTest.assertValues(["16"])
      minuteTest.assertValues(["34"])
      secondTest.assertValues(["02"])

      fractionalSecondScheduler.advance(by: .milliseconds(500))

      // Waiting the additional half second causes new countdown values to be emitted.
      dayTest.assertValues(["01", "01"])
      hourTest.assertValues(["16", "16"])
      minuteTest.assertValues(["34", "34"])
      secondTest.assertValues(["02", "01"])

      fractionalSecondScheduler.advance(by: .seconds(1))

      dayTest.assertValues(["01", "01", "01"])
      hourTest.assertValues(["16", "16", "16"])
      minuteTest.assertValues(["34", "34", "34"])
      secondTest.assertValues(["02", "01", "00"])

      fractionalSecondScheduler.advance(by: .seconds(1))

      dayTest.assertValues(["01", "01", "01", "01"])
      hourTest.assertValues(["16", "16", "16", "16"])
      minuteTest.assertValues(["34", "34", "34", "33"])
      secondTest.assertValues(["02", "01", "00", "59"])
    }
  }

  func testCountdownProducer_CompletesWhenReachesDate() {
    let countdown = countdownProducer(to: MockDate().addingTimeInterval(2).date)

    let dayTest = TestObserver<String, NoError>()
    let hourTest = TestObserver<String, NoError>()
    let minuteTest = TestObserver<String, NoError>()
    let secondTest = TestObserver<String, NoError>()

    countdown.map { $0.day }.start(dayTest.observer)
    countdown.map { $0.hour }.start(hourTest.observer)
    countdown.map { $0.minute }.start(minuteTest.observer)
    countdown.map { $0.second }.start(secondTest.observer)

    dayTest.assertValues(["00"])
    hourTest.assertValues(["00"])
    minuteTest.assertValues(["00"])
    secondTest.assertValues(["02"])

    self.scheduler.advance(by: .seconds(1))

    dayTest.assertValues(["00", "00"])
    hourTest.assertValues(["00", "00"])
    minuteTest.assertValues(["00", "00"])
    secondTest.assertValues(["02", "01"])

    self.scheduler.advance(by: .seconds(1))

    dayTest.assertValues(["00", "00", "00"])
    hourTest.assertValues(["00", "00", "00"])
    minuteTest.assertValues(["00", "00", "00"])
    secondTest.assertValues(["02", "01", "00"])
    dayTest.assertDidNotComplete()
    hourTest.assertDidNotComplete()
    minuteTest.assertDidNotComplete()
    secondTest.assertDidNotComplete()

    self.scheduler.advance(by: .seconds(1))

    dayTest.assertValues(["00", "00", "00"])
    hourTest.assertValues(["00", "00", "00"])
    minuteTest.assertValues(["00", "00", "00"])
    secondTest.assertValues(["02", "01", "00"])
    dayTest.assertDidComplete()
    hourTest.assertDidComplete()
    minuteTest.assertDidComplete()
    secondTest.assertDidComplete()

    self.scheduler.advance(by: .seconds(1))

    dayTest.assertValues(["00", "00", "00"])
    hourTest.assertValues(["00", "00", "00"])
    minuteTest.assertValues(["00", "00", "00"])
    secondTest.assertValues(["02", "01", "00"])
  }

  func testOnePasswordButtonIsHidden() {
    var iOS12: (Double) -> Bool = { _ in true }
    withEnvironment(isOSVersionAvailable: iOS12) {
      XCTAssertTrue(is1PasswordButtonHidden(true))
      XCTAssertTrue(is1PasswordButtonHidden(false))
    }

    iOS12 = { _ in false }
    withEnvironment(isOSVersionAvailable: iOS12) {
      XCTAssertTrue(is1PasswordButtonHidden(true))
      XCTAssertFalse(is1PasswordButtonHidden(false))
    }
  }

  func testIsOSVersionAvailable_Supports_iOS12() {
    XCTAssertTrue(ksr_isOSVersionAvailable(12.0))
    XCTAssertTrue(ksr_isOSVersionAvailable(12.1))
    XCTAssertTrue(ksr_isOSVersionAvailable(12.123))
    XCTAssertTrue(ksr_isOSVersionAvailable(12.9))
  }

  func testAttributedStringWithLinks() {
    let string1 = "What a lovely string with a link and another link" as NSString
    let attrString1 = NSAttributedString(string: string1 as String)
    let links: [AttributedLinkData] = [
      ("a link", URL(string: "link://a_link"), [.foregroundColor: UIColor.blue]),
      ("another link", URL(string: "link://another_link"), [:])
    ]
    let string1WithLinks = ksr_attributedString(attrString1, with: links)

    let aLinkRange = string1.range(of: "a link")
    let anotherLinkRange = string1.range(of: "another link")
    let fullRange = string1.range(of: string1 as String)

    let string1Link1Attribute = string1WithLinks
      .attribute(.link, at: aLinkRange.location, longestEffectiveRange: nil, in: fullRange)
    let string1Link1ColorAttribute = string1WithLinks
      .attribute(.foregroundColor, at: aLinkRange.location, longestEffectiveRange: nil, in: fullRange)
    let string1Link2Attribute = string1WithLinks
      .attribute(.link, at: anotherLinkRange.location, longestEffectiveRange: nil, in: fullRange)
    let string1Link2ColorAttribute = string1WithLinks
      .attribute(.foregroundColor, at: anotherLinkRange.location, longestEffectiveRange: nil, in: fullRange)

    XCTAssertNotNil(string1Link1Attribute, "a link is a link")
    XCTAssertNotNil(string1Link1ColorAttribute, "a link has a foreground color")
    XCTAssertNotNil(string1Link2Attribute, "another link is a link")
    XCTAssertNil(string1Link2ColorAttribute, "another link has no foreground color")
  }

  func testByPledgingYouAgree() {
    let string = Strings.By_pledging_you_agree() as NSString
    let attrString = NSAttributedString(string: string as String)
    let links: [AttributedLinkData] = [
      ("Terms of Use", URL(string: "link://terms_of_use"), [:]),
      ("Privacy Policy", URL(string: "link://privacy_policy"), [:]),
      ("Cookie Policy", URL(string: "link://cookie_policy"), [:])
    ]

    let attrStringWithLinks = ksr_attributedString(attrString, with: links)

    let termsLinkRange = string.range(of: "Terms of Use")
    let privacyLinkRange = string.range(of: "Privacy Policy")
    let cookieLinkRange = string.range(of: "Cookie Policy")
    let fullRange = string.range(of: string as String)

    let termsLinkAttribute = attrStringWithLinks
      .attribute(.link, at: termsLinkRange.location, longestEffectiveRange: nil, in: fullRange)

    let privacyLinkAttribute = attrStringWithLinks
      .attribute(.link, at: privacyLinkRange.location, longestEffectiveRange: nil, in: fullRange)

    let cookieLinkAttribute = attrStringWithLinks
      .attribute(.link, at: cookieLinkRange.location, longestEffectiveRange: nil, in: fullRange)

    XCTAssertNotNil(termsLinkAttribute)
    XCTAssertNotNil(privacyLinkAttribute)
    XCTAssertNotNil(cookieLinkAttribute)
  }
}
