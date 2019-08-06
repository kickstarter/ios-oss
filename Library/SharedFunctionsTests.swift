import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

// swiftlint:disable line_length
final class SharedFunctionsTests: TestCase {
  func testCountdownProducer() {
    // swiftlint:disable:next line_length
    let future: TimeInterval = TimeInterval(1 * 60 * 60 * 24) + TimeInterval(16 * 60 * 60) + TimeInterval(34 * 60) + 2
    let futureDate = MockDate().addingTimeInterval(future).date
    let countdown = countdownProducer(to: futureDate)

    let dayTest = TestObserver<String, Never>()
    let hourTest = TestObserver<String, Never>()
    let minuteTest = TestObserver<String, Never>()
    let secondTest = TestObserver<String, Never>()

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
      // swiftlint:disable:next line_length
      let future: TimeInterval = TimeInterval(1 * 60 * 60 * 24) + TimeInterval(16 * 60 * 60) + TimeInterval(34 * 60) + 2
      let futureDate = MockDate().addingTimeInterval(future).date
      let countdown = countdownProducer(to: futureDate)

      let dayTest = TestObserver<String, Never>()
      let hourTest = TestObserver<String, Never>()
      let minuteTest = TestObserver<String, Never>()
      let secondTest = TestObserver<String, Never>()

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

    let dayTest = TestObserver<String, Never>()
    let hourTest = TestObserver<String, Never>()
    let minuteTest = TestObserver<String, Never>()
    let secondTest = TestObserver<String, Never>()

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
    withEnvironment(is1PasswordSupported: { true }) {
      XCTAssertTrue(is1PasswordButtonHidden(true))
      XCTAssertFalse(is1PasswordButtonHidden(false))
    }

    withEnvironment(is1PasswordSupported: { false }) {
      XCTAssertTrue(is1PasswordButtonHidden(true))
      XCTAssertTrue(is1PasswordButtonHidden(false))
    }
  }

  func testDefaultShippingRule_Empty() {
    XCTAssertEqual(nil, defaultShippingRule(fromShippingRules: []))
  }

  func testDefaultShippingRule_DoesNotMatchCountryCode_DoesNotMatchUSA() {
    let config = Config.template
      |> Config.lens.countryCode .~ "JP"

    withEnvironment(config: config) {
      let locations = [
        Location.template |> Location.lens.country .~ "DE",
        Location.template |> Location.lens.country .~ "CZ",
        Location.template |> Location.lens.country .~ "CA"
      ]
      let shippingRule = defaultShippingRule(
        fromShippingRules: locations.map { ShippingRule.template |> ShippingRule.lens.location .~ $0 }
      )
      XCTAssertEqual("DE", shippingRule?.location.country)
    }
  }

  func testDefaultShippingRule_DoesNotMatchCountryCode_MatchesUSA() {
    let config = Config.template
      |> Config.lens.countryCode .~ "JP"

    withEnvironment(config: config) {
      let locations = [
        Location.template |> Location.lens.country .~ "US",
        Location.template |> Location.lens.country .~ "CZ",
        Location.template |> Location.lens.country .~ "CA"
      ]
      let shippingRule = defaultShippingRule(
        fromShippingRules: locations.map { ShippingRule.template |> ShippingRule.lens.location .~ $0 }
      )
      XCTAssertEqual("US", shippingRule?.location.country)
    }
  }

  func testDefaultShippingRule_MatchesCountryCode() {
    let config = Config.template
      |> Config.lens.countryCode .~ "CZ"

    withEnvironment(config: config) {
      let locations = [
        Location.template |> Location.lens.country .~ "US",
        Location.template |> Location.lens.country .~ "CZ",
        Location.template |> Location.lens.country .~ "CA"
      ]
      let shippingRule = defaultShippingRule(
        fromShippingRules: locations.map { ShippingRule.template |> ShippingRule.lens.location .~ $0 }
      )
      XCTAssertEqual("CZ", shippingRule?.location.country)
    }
  }

  func testUpdatedUserWithClearedActivityCountProducer_Success() {
    let initialActivitiesCount = 100
    let values = TestObserver<User, Never>()

    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = initialActivitiesCount

    let mockService = MockService(
      clearUserUnseenActivityResult: Result(success: .init(activityIndicatorCount: 0))
    )

    let user = User.template
      |> User.lens.unseenActivityCount .~ initialActivitiesCount

    XCTAssertEqual(values.values.map { $0.id }, [])

    withEnvironment(apiService: mockService, application: mockApplication, currentUser: user) {
      _ = updatedUserWithClearedActivityCountProducer()
        .start(on: AppEnvironment.current.scheduler)
        .start(values.observer)

      self.scheduler.advance()

      XCTAssertEqual(values.values.map { $0.id }, [1])
    }
  }

  func testUpdatedUserWithClearedActivityCountProducer_Failure() {
    let initialActivitiesCount = 100
    let values = TestObserver<User, Never>()

    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = initialActivitiesCount

    let mockService = MockService(
      clearUserUnseenActivityResult: Result(failure: .invalidInput)
    )

    let user = User.template
      |> User.lens.unseenActivityCount .~ initialActivitiesCount

    XCTAssertEqual(values.values.map { $0.id }, [])

    withEnvironment(apiService: mockService, application: mockApplication, currentUser: user) {
      _ = updatedUserWithClearedActivityCountProducer()
        .start(on: AppEnvironment.current.scheduler)
        .start(values.observer)

      self.scheduler.advance()

      XCTAssertEqual(values.values.map { $0.id }, [])
    }
  }
}
