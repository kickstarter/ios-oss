import Prelude
import ReactiveSwift
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
  private let projectImageUrl = TestObserver<String, NoError>()
  private let pushLiveStreamViewControllerProject = TestObserver<Project, NoError>()
  private let pushLiveStreamViewControllerLiveStream = TestObserver<Project.LiveStream, NoError>()
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
    self.vm.outputs.projectImageUrl.map { $0.absoluteString }.observe(self.projectImageUrl.observer)
    self.vm.outputs.pushLiveStreamViewController.map(first).observe(
      self.pushLiveStreamViewControllerProject.observer)
    self.vm.outputs.pushLiveStreamViewController.map(second)
      .observe(self.pushLiveStreamViewControllerLiveStream.observer)
    self.vm.outputs.pushLiveStreamViewController.map(third).observe(
      self.pushLiveStreamViewControllerEvent.observer)
    self.vm.outputs.secondsString.map { $0.string }.observe(self.seconds.observer)
    self.vm.outputs.upcomingIntroText.map { $0.string }.observe(self.upcomingIntroText.observer)
    self.vm.outputs.viewControllerTitle.observe(self.viewControllerTitle.observer)
  }

  func testUpcomingIntroText() {
    let project = Project.template
      |> Project.lens.creator.name .~ "Creator Name"

    self.vm.inputs.configureWith(project: project, liveStream: .template)
    self.vm.inputs.viewDidLoad()

    self.upcomingIntroText.assertValues(["Upcoming with\nCreator Name"])
  }

  func testCountdownLabels() {
    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ futureDate().timeIntervalSince1970

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.days.assertValueCount(0)
    self.hours.assertValueCount(0)
    self.minutes.assertValueCount(0)
    self.seconds.assertValueCount(0)

    // Step 1: Set project and liveStream
    self.vm.inputs.configureWith(project: project, liveStream: liveStream)
    self.vm.inputs.viewDidLoad()

    self.days.assertValues(["10\ndays"])
    self.hours.assertValues(["07\nhours"])
    self.minutes.assertValues(["24\nminutes"])
    self.seconds.assertValues(["45\nseconds"])

    // Step 2: Set date as if two seconds have passed
    self.scheduler.advance(by: .seconds(2))

    self.days.assertValues(["10\ndays"])
    self.hours.assertValues(["07\nhours"])
    self.minutes.assertValues(["24\nminutes"])
    self.seconds.assertValues(["45\nseconds", "44\nseconds", "43\nseconds"])
  }

  func testCountdownEnded() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (self.scheduler.currentDate.timeIntervalSince1970 + 10)

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.vm.inputs.configureWith(project: project, liveStream: liveStream)
    self.vm.inputs.viewDidLoad()

    let event = LiveStreamEvent.template
    self.vm.inputs.retrievedLiveStreamEvent(event: event)

    self.pushLiveStreamViewControllerProject.assertValueCount(0)
    self.pushLiveStreamViewControllerEvent.assertValueCount(0)

    self.scheduler.advance(by: .seconds(2))

    self.pushLiveStreamViewControllerProject.assertValueCount(0)
    self.pushLiveStreamViewControllerEvent.assertValueCount(0)

    self.scheduler.advance(by: .seconds(8))

    self.pushLiveStreamViewControllerProject.assertValueCount(0)
    self.pushLiveStreamViewControllerEvent.assertValueCount(0)

    self.scheduler.advance(by: .seconds(1))

    self.pushLiveStreamViewControllerProject.assertValues([project])
    self.pushLiveStreamViewControllerEvent.assertValues([event])

    XCTAssertTrue(self.pushLiveStreamViewControllerProject.lastValue?.liveStreams.first?.isLiveNow ?? false)
    XCTAssertTrue(self.pushLiveStreamViewControllerEvent.lastValue?.stream.liveNow ?? false)
  }

  func testClose() {
    self.vm.inputs.configureWith(project: .template, liveStream: .template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testCategoryId() {
    let project = Project.template
      |> Project.lens.category.id .~ 123

    self.vm.inputs.configureWith(project: project, liveStream: .template)
    self.vm.inputs.viewDidLoad()

    self.categoryId.assertValue(123)
  }

  func testProjectImageUrl() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, liveStream: .template)
    self.vm.inputs.viewDidLoad()

    self.projectImageUrl.assertValues(["http://www.kickstarter.com/full.jpg"])
  }

  func testViewControllerTitle() {
    self.vm.inputs.configureWith(project: .template, liveStream: .template)
    self.vm.inputs.viewDidLoad()

    self.viewControllerTitle.assertValue("Live stream countdown")
  }
}

//swiftlint:disable force_unwrapping
private func futureDate() -> Date {
  var components = DateComponents()
  components.year = 2016
  components.day = 12
  components.month = 10
  components.hour = 8

  return AppEnvironment.current.calendar.date(from: components)!
}

private func nowDate() -> Date {
  var components = DateComponents()
  components.year = 2016
  components.day = 25
  components.month = 12
  components.hour = 12
  components.minute = 6
  components.second = 34

  return AppEnvironment.current.calendar.date(from: components)!
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
