import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamCountdownViewModelTests: XCTestCase {
  private let vm: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()

  private let categoryId = TestObserver<Int, NoError>()
  private let days = TestObserver<(String, String), NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let hours = TestObserver<(String, String), NoError>()
  private let minutes = TestObserver<(String, String), NoError>()
  private let projectImageUrl = TestObserver<NSURL, NoError>()
  private let pushLiveStreamViewController = TestObserver<(Project, LiveStreamEvent), NoError>()
  private let seconds = TestObserver<(String, String), NoError>()
  private let viewControllerTitle = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.categoryId.observe(self.categoryId.observer)
    self.vm.outputs.daysString.observe(self.days.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.hoursString.observe(self.hours.observer)
    self.vm.outputs.minutesString.observe(self.minutes.observer)
    self.vm.outputs.projectImageUrl.observe(self.projectImageUrl.observer)
    self.vm.outputs.pushLiveStreamViewController.observe(self.pushLiveStreamViewController.observer)
    self.vm.outputs.secondsString.observe(self.seconds.observer)
    self.vm.outputs.viewControllerTitle.observe(self.viewControllerTitle.observer)
  }

  func testDateComparison() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.startDate .~ futureDate().timeIntervalSince1970

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    // Step 1: Set project and date
    self.vm.inputs.configureWith(project: project, now: nowDate())
    self.vm.inputs.setNow(date: nowDate())
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.days.lastValue == ("10", "days"))
    XCTAssertTrue(self.hours.lastValue == ("19", "hours"))
    XCTAssertTrue(self.minutes.lastValue == ("53", "minutes"))
    XCTAssertTrue(self.seconds.lastValue == ("26", "seconds"))

    // Step 2: Set date as if two days have passed
    _ = AppEnvironment.current.calendar.dateByAddingUnit(.Day,
      value: 2, toDate: nowDate(), options: []).flatMap { self.vm.inputs.setNow(date: $0) }

    XCTAssertTrue(self.days.lastValue == ("08", "days"))
    XCTAssertTrue(self.hours.lastValue == ("19", "hours"))
    XCTAssertTrue(self.minutes.lastValue == ("53", "minutes"))
    XCTAssertTrue(self.seconds.lastValue == ("26", "seconds"))

    let event = LiveStreamEvent.template

    // Step 3: Set the event
    self.vm.inputs.setLiveStreamEvent(event: event)

    // Step 4: Set now to a second past the stream's start date
    // The live stream view controller should be pushed
    _ = AppEnvironment.current.calendar.dateByAddingUnit(.Second,
      value: 1, toDate: futureDate(), options: []).flatMap { self.vm.inputs.setNow(date: $0) }

    XCTAssertTrue(self.pushLiveStreamViewController.lastValue == (project, event))
  }

  func testClose() {
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testCategoryId() {
    let project = Project.template
      |> Project.lens.category.id .~ 123

    self.vm.inputs.configureWith(project: project, now: nowDate())
    self.vm.inputs.viewDidLoad()

    self.categoryId.assertValue(123)
  }

  func testProjectImageUrl() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, now: nowDate())
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.projectImageUrl.lastValue?.absoluteString == "http://www.kickstarter.com/full.jpg")
  }

  func testViewControllerTitle() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, now: nowDate())
    self.vm.inputs.viewDidLoad()

    self.viewControllerTitle.assertValue("Live stream countdown")
  }
}

//swiftlint:disable force_unwrapping
private func futureDate() -> NSDate {
  let components = NSDateComponents()
  components.year = 2017
  components.day = 5
  components.month = 1
  components.hour = 8

  return AppEnvironment.current.calendar.dateFromComponents(components)!
}

private func nowDate() -> NSDate {
  let components = NSDateComponents()
  components.year = 2016
  components.day = 25
  components.month = 12
  components.hour = 12
  components.minute = 6
  components.second = 34

  return AppEnvironment.current.calendar.dateFromComponents(components)!
}
//swiftlint:enable force_unwrapping

private func == (tuple1: (String, String)?, tuple2: (String, String)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}

private func == (tuple1: (Project, LiveStreamEvent)?, tuple2: (Project, LiveStreamEvent)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}
