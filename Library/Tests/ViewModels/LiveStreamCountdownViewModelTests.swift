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
  private let countdownAccessibilityLabel = TestObserver<String, NoError>()
  private let countdownDateLabelText = TestObserver<String, NoError>()
  private let days = TestObserver<String, NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let hours = TestObserver<String, NoError>()
  private let minutes = TestObserver<String, NoError>()
  private let projectImageUrl = TestObserver<String?, NoError>()
  private let pushLiveStreamViewControllerProject = TestObserver<Project, NoError>()
  private let pushLiveStreamViewControllerLiveStream = TestObserver<Project.LiveStream, NoError>()
  private let pushLiveStreamViewControllerEvent = TestObserver<LiveStreamEvent, NoError>()
  private let seconds = TestObserver<String, NoError>()
  private let upcomingIntroText = TestObserver<String, NoError>()
  private let viewControllerTitle = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.categoryId.observe(self.categoryId.observer)
    self.vm.outputs.countdownAccessibilityLabel.observe(self.countdownAccessibilityLabel.observer)
    self.vm.outputs.countdownDateLabelText.observe(self.countdownDateLabelText.observer)
    self.vm.outputs.daysString.observe(self.days.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.hoursString.observe(self.hours.observer)
    self.vm.outputs.minutesString.observe(self.minutes.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString }
      .observe(self.projectImageUrl.observer)
    self.vm.outputs.pushLiveStreamViewController.map(first).observe(
      self.pushLiveStreamViewControllerProject.observer)
    self.vm.outputs.pushLiveStreamViewController.map(second)
      .observe(self.pushLiveStreamViewControllerLiveStream.observer)
    self.vm.outputs.pushLiveStreamViewController.map(third).observe(
      self.pushLiveStreamViewControllerEvent.observer)
    self.vm.outputs.secondsString.observe(self.seconds.observer)
    self.vm.outputs.upcomingIntroText.observe(self.upcomingIntroText.observer)
    self.vm.outputs.viewControllerTitle.observe(self.viewControllerTitle.observer)
  }

  func testUpcomingIntroText() {
    let project = Project.template
      |> Project.lens.creator.name .~ "Creator Name"

    self.vm.inputs.configureWith(project: project, liveStream: .template, context: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.upcomingIntroText.assertValues(["Upcoming with<br/><b>Creator Name</b>"])
  }

  func testTrackViewedLiveStreamCountdown() {
    let context = Koala.LiveStreamContext.projectPage

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "context", as: String.self))

    self.vm.inputs.configureWith(project: .template, liveStream: .template, context: context)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream Countdown"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "context", as: String.self))
  }

  func testCountdownLabelText() {
    let future: TimeInterval = TimeInterval(2*60*60*24) + TimeInterval(11*60*60) + TimeInterval(5*60) + 22
    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + future)

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.countdownDateLabelText.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, liveStream: liveStream)
    self.vm.inputs.viewDidLoad()

    self.countdownDateLabelText.assertValues(["Oct 4, 9:40 AM GMT"])
  }

  func testCountdownLabels() {
    let future: TimeInterval = TimeInterval(2*60*60*24) + TimeInterval(11*60*60) + TimeInterval(5*60) + 22
    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + future)

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.days.assertValueCount(0)
    self.hours.assertValueCount(0)
    self.minutes.assertValueCount(0)
    self.seconds.assertValueCount(0)

    // Step 1: Set project and liveStream
    self.vm.inputs.configureWith(project: project, liveStream: liveStream, context: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.days.assertValues(["02"])
    self.hours.assertValues(["11"])
    self.minutes.assertValues(["05"])
    self.seconds.assertValues(["22"])

    // Step 2: Set date as if two seconds have passed
    self.scheduler.advance(by: .seconds(2))

    self.days.assertValues(["02"])
    self.hours.assertValues(["11"])
    self.minutes.assertValues(["05"])
    self.seconds.assertValues(["22", "21", "20"])
  }

  func testCountdownAccessibilityLabel() {
    let future: TimeInterval = TimeInterval(2*60*60*24) + TimeInterval(11*60*60) + TimeInterval(5*60) + 22
    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + future)

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.countdownAccessibilityLabel.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, liveStream: liveStream, context: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.countdownAccessibilityLabel.assertValues(["The live stream will start in 2 days."])
  }

  func testCountdownEnded() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (self.scheduler.currentDate.timeIntervalSince1970 + 10)

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, liveStream: liveStream, context: .projectPage)
    self.vm.inputs.viewDidLoad()

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

    XCTAssertTrue(self.pushLiveStreamViewControllerLiveStream.lastValue?.isLiveNow ?? false)
    XCTAssertTrue(self.pushLiveStreamViewControllerProject.lastValue?.liveStreams.first?.isLiveNow ?? false)
    XCTAssertTrue(self.pushLiveStreamViewControllerEvent.lastValue?.stream.liveNow ?? false)
  }

  func testClose() {
    self.vm.inputs.configureWith(project: .template, liveStream: .template, context: .projectPage)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testCategoryId() {
    let project = Project.template
      |> Project.lens.category.id .~ 123

    self.vm.inputs.configureWith(project: project, liveStream: .template, context: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.categoryId.assertValue(123)
  }

  func testProjectImageUrl() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, liveStream: .template, context: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.projectImageUrl.assertValues(["http://www.kickstarter.com/full.jpg"])
  }

  func testViewControllerTitle() {
    self.vm.inputs.configureWith(project: .template, liveStream: .template, context: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.viewControllerTitle.assertValue("Live stream countdown")
  }
}

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
