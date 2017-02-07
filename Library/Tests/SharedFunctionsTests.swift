import Foundation
import ReactiveSwift
import Result
@testable import Library
@testable import ReactiveExtensions_TestHelpers

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
}
