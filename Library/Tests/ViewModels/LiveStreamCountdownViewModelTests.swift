import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamCountdownViewModelTests: TestCase {
  private let vm: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()

  private let categoryId = TestObserver<Int, NoError>()
  private let days = TestObserver<String, NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let hours = TestObserver<String, NoError>()
  private let minutes = TestObserver<String, NoError>()
  private let projectImageUrl = TestObserver<NSURL, NoError>()
  private let pushLiveStreamViewControllerProject = TestObserver<Project, NoError>()
  private let pushLiveStreamViewControllerEvent = TestObserver<LiveStreamEvent, NoError>()
  private let seconds = TestObserver<String, NoError>()
  private let upcomingIntroText = TestObserver<String, NoError>()
  private let viewControllerTitle = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.categoryId.observe(self.categoryId.observer)
    self.vm.outputs.daysString.map { $0.string }.observe(self.days.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.hoursString.map { $0.string }.observe(self.hours.observer)
    self.vm.outputs.minutesString.map { $0.string }.observe(self.minutes.observer)
    self.vm.outputs.projectImageUrl.observe(self.projectImageUrl.observer)
    self.vm.outputs.pushLiveStreamViewController.map(first).observe(
      self.pushLiveStreamViewControllerProject.observer)
    self.vm.outputs.pushLiveStreamViewController.map(second).observe(
      self.pushLiveStreamViewControllerEvent.observer)
    self.vm.outputs.secondsString.map { $0.string }.observe(self.seconds.observer)
    self.vm.outputs.upcomingIntroText.map { $0.string }.observe(self.upcomingIntroText.observer)
    self.vm.outputs.viewControllerTitle.observe(self.viewControllerTitle.observer)
  }

  func testUpcomingIntroText() {
    let project = Project.template
      |> Project.lens.creator.name .~ "Creator Name"

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.upcomingIntroText.assertValues(["Upcoming with\nCreator Name"])
  }

  func testDateComparison() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.startDate .~ MockDate(
        timeIntervalSince1970: futureDate().timeIntervalSince1970).date.timeIntervalSince1970

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.days.assertValueCount(0)
    self.hours.assertValueCount(0)
    self.minutes.assertValueCount(0)
    self.seconds.assertValueCount(0)

    // Step 1: Set project and date
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.days.assertValues(["10\ndays"])
    self.hours.assertValues(["07\nhours"])
    self.minutes.assertValues(["24\nminutes"])
    self.seconds.assertValues(["45\nseconds"])

    //FIXME: once we have a way to advance the test scheduler in such a way that time can pass we can fix this test

    // Step 2: Set date as if two days have passed
    self.scheduler.advanceByInterval(2)

    self.days.assertValues(["10\ndays"])
    self.hours.assertValues(["07\nhours"])
    self.minutes.assertValues(["24\nminutes"])
    self.seconds.assertValues(["45\nseconds", "44\nseconds", "43\nseconds"])

    // Step 3: Set now to a second past the stream's start date
    // The live stream view controller should be pushed

    let event = LiveStreamEvent.template

    // Step 4: Set the event
    // The event could be set at any time but it's required for pushing the live stream
    self.vm.inputs.retrievedLiveStreamEvent(event: event)

//    self.pushLiveStreamViewControllerProject.assertValues([project])
//    self.pushLiveStreamViewControllerEvent.assertValues([event])
  }

  func testClose() {
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testCategoryId() {
    let project = Project.template
      |> Project.lens.category.id .~ 123

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.categoryId.assertValue(123)
  }

  func testProjectImageUrl() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.projectImageUrl.lastValue?.absoluteString == "http://www.kickstarter.com/full.jpg")
  }

  func testViewControllerTitle() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.viewControllerTitle.assertValue("Live stream countdown")
  }
}

//swiftlint:disable force_unwrapping
private func futureDate() -> NSDate {
  let components = NSDateComponents()
  components.year = 2016
  components.day = 12
  components.month = 10
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
