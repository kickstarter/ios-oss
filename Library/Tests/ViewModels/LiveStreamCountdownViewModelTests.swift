import Prelude
import ReactiveCocoa
import Result
import WebKit
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamCountdownViewModelTests: XCTestCase {
  private let vm: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()
  private let days = TestObserver<(String, String), NoError>()
  private let hours = TestObserver<(String, String), NoError>()
  private let minutes = TestObserver<(String, String), NoError>()
  private let seconds = TestObserver<(String, String), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.daysString.observe(self.days.observer)
    self.vm.outputs.hoursString.observe(self.hours.observer)
    self.vm.outputs.minutesString.observe(self.minutes.observer)
    self.vm.outputs.secondsString.observe(self.seconds.observer)
  }

  func testDateComparison() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.setNow(nowDate())
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.days.lastValue == ("10", "days"))
    XCTAssertTrue(self.hours.lastValue == ("19", "hours"))
    XCTAssertTrue(self.minutes.lastValue == ("53", "minutes"))
    XCTAssertTrue(self.seconds.lastValue == ("26", "seconds"))
  }
}

//swiftlint:disable force_unwrapping
private func futureDate() -> NSDate {
  let components = NSDateComponents()
  components.year = 2017
  components.day = 5
  components.month = 1
  components.hour = 8

  return NSCalendar.currentCalendar().dateFromComponents(components)!
}

private func nowDate() -> NSDate {
  let components = NSDateComponents()
  components.year = 2016
  components.day = 25
  components.month = 12
  components.hour = 12
  components.minute = 6
  components.second = 34

  return NSCalendar.currentCalendar().dateFromComponents(components)!
}
//swiftlint:enable force_unwrapping

private func == (tuple1: (String, String)?, tuple2: (String, String)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}
