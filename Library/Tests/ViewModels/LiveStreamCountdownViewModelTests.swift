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
  private let pushLiveStreamViewControllerEvent = TestObserver<LiveStreamEvent, NoError>()
  private let pushLiveStreamViewControllerRefTag = TestObserver<RefTag, NoError>()
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
    self.vm.outputs.pushLiveStreamViewController.map(second).observe(
      self.pushLiveStreamViewControllerEvent.observer)
    self.vm.outputs.pushLiveStreamViewController.map(third).observe(
      self.pushLiveStreamViewControllerRefTag.observer)
    self.vm.outputs.secondsString.observe(self.seconds.observer)
    self.vm.outputs.upcomingIntroText.observe(self.upcomingIntroText.observer)
    self.vm.outputs.viewControllerTitle.observe(self.viewControllerTitle.observer)
  }

  func testUpcomingIntroText() {
    let project = Project.template
      |> Project.lens.creator.name .~ "Creator Name"

    self.vm.inputs.configureWith(project: project, liveStreamEvent: .template, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.upcomingIntroText.assertValues(["Upcoming with<br/><b>Creator Name</b>"])
  }

  func testTrackViewedLiveStreamCountdown() {
    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream Countdown"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))
  }

  func testCountdownLabelText() {
    let future: TimeInterval = TimeInterval(2*60*60*24) + TimeInterval(11*60*60) + TimeInterval(5*60) + 22
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date

    self.countdownDateLabelText.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.countdownDateLabelText.assertValues(["Oct 4, 9:40 AM GMT"])
  }

  func testCountdownLabels() {
    let future: TimeInterval = TimeInterval(2*60*60*24) + TimeInterval(11*60*60) + TimeInterval(5*60) + 22
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date

    self.days.assertValueCount(0)
    self.hours.assertValueCount(0)
    self.minutes.assertValueCount(0)
    self.seconds.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.days.assertValues(["02"])
    self.hours.assertValues(["11"])
    self.minutes.assertValues(["05"])
    self.seconds.assertValues(["22"])

    self.scheduler.advance(by: .seconds(2))

    self.days.assertValues(["02"])
    self.hours.assertValues(["11"])
    self.minutes.assertValues(["05"])
    self.seconds.assertValues(["22", "21", "20"])
  }

  func testCountdownAccessibilityLabel() {
    let future: TimeInterval = TimeInterval(2*60*60*24) + TimeInterval(11*60*60) + TimeInterval(5*60) + 22
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date

    self.countdownAccessibilityLabel.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.countdownAccessibilityLabel.assertValues(["The live stream will start in 2 days."])
  }

  func testCountdownEnded() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(10).date

    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, liveStreamEvent: liveStreamEvent, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

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

    XCTAssertTrue(self.pushLiveStreamViewControllerEvent.lastValue?.liveNow ?? false)
    XCTAssertEqual(.liveStreamCountdown, self.pushLiveStreamViewControllerRefTag.lastValue)
  }

  func testClose() {
    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testTrackClosedLiveStreamCountdown() {
    let project = Project.template
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(100).date

    XCTAssertEqual([], self.trackingClient.events)
    XCTAssertEqual([], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.vm.inputs.configureWith(project: project, liveStreamEvent: liveStreamEvent, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Live Stream Countdown"], self.trackingClient.events)
    XCTAssertEqual(["project_page"], self.trackingClient.properties(forKey: "ref_tag", as: String.self))

    self.scheduler.advance(by: .seconds(50))

    self.vm.inputs.closeButtonTapped()

    XCTAssertEqual(["Viewed Live Stream Countdown", "Closed Live Stream"], self.trackingClient.events)
    XCTAssertEqual(["project_page", "project_page"], self.trackingClient.properties(forKey: "ref_tag",
                                                                                    as: String.self))
    XCTAssertEqual([nil, "live_stream_countdown"], self.trackingClient.properties(forKey: "type",
                                                                             as: String.self))
    XCTAssertEqual([nil, 50], self.trackingClient.properties(forKey: "duration", as: Double.self))
  }

  func testCategoryId() {
    let project = Project.template
      |> Project.lens.category.id .~ 123

    self.vm.inputs.configureWith(project: project, liveStreamEvent: .template, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.categoryId.assertValue(123)
  }

  func testProjectImageUrl() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, liveStreamEvent: .template, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.projectImageUrl.assertValues([nil, "http://www.kickstarter.com/full.jpg"])
  }

  func testViewControllerTitle() {
    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, refTag: .projectPage)
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
