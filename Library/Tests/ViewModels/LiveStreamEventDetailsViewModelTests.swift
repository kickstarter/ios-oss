import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamEventDetailsViewModelTests: TestCase {
  private let vm: LiveStreamEventDetailsViewModelType = LiveStreamEventDetailsViewModel()

  private let availableForText = TestObserver<String, NoError>()
  private let creatorAvatarUrl = TestObserver<NSURL, NoError>()
  private let creatorName = TestObserver<String, NoError>()
  private let configureSharing = TestObserver<(Project, LiveStreamEvent), NoError>()
  private let error = TestObserver<String, NoError>()
  private let introText = TestObserver<NSAttributedString, NoError>()
  private let liveStreamTitle = TestObserver<String, NoError>()
  private let liveStreamParagraph = TestObserver<String, NoError>()
  private let numberOfPeopleWatchingText = TestObserver<String, NoError>()
  private let retrieveEventInfo = TestObserver<String, NoError>()
  private let showActivityIndicator = TestObserver<Bool, NoError>()
  private let showSubscribeButtonActivityIndicator = TestObserver<Bool, NoError>()
  private let subscribeButtonText = TestObserver<String, NoError>()
  private let subscribeButtonImage = TestObserver<UIImage?, NoError>()
  private let subscribed = TestObserver<Bool, NoError>()
  private let subscribeLabelText = TestObserver<String, NoError>()
  private let toggleSubscribe = TestObserver<(String, Bool), NoError>()
  private let upcomingIntroText = TestObserver<NSAttributedString, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.availableForText.observe(self.availableForText.observer)
    self.vm.outputs.creatorAvatarUrl.observe(self.creatorAvatarUrl.observer)
    self.vm.outputs.creatorName.observe(self.creatorName.observer)
    self.vm.outputs.configureSharing.observe(self.configureSharing.observer)
    self.vm.outputs.error.observe(self.error.observer)
    self.vm.outputs.introText.observe(self.introText.observer)
    self.vm.outputs.liveStreamTitle.observe(self.liveStreamTitle.observer)
    self.vm.outputs.liveStreamParagraph.observe(self.liveStreamParagraph.observer)
    self.vm.outputs.numberOfPeopleWatchingText.observe(self.numberOfPeopleWatchingText.observer)
    self.vm.outputs.retrieveEventInfo.observe(self.retrieveEventInfo.observer)
    self.vm.outputs.showActivityIndicator.observe(self.showActivityIndicator.observer)
    self.vm.outputs.showSubscribeButtonActivityIndicator.observe(
      self.showSubscribeButtonActivityIndicator.observer)
    self.vm.outputs.subscribeButtonText.observe(self.subscribeButtonText.observer)
    self.vm.outputs.subscribeButtonImage.observe(self.subscribeButtonImage.observer)
    self.vm.outputs.subscribed.observe(self.subscribed.observer)
    self.vm.outputs.subscribeLabelText.observe(self.subscribeLabelText.observer)
    self.vm.outputs.toggleSubscribe.observe(self.toggleSubscribe.observer)
    self.vm.outputs.upcomingIntroText.observe(self.upcomingIntroText.observer)
  }

  func testAvailableForText() {
    let stream = LiveStreamEvent.template.stream
      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream .~ stream

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.availableForText.assertValue("Available to watch for 2 more days")
  }

  func testCreatorAvatarUrl() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(
      self.creatorAvatarUrl.lastValue?.absoluteString == "https://www.kickstarter.com/creator-avatar.jpg")
  }

  func testCreatorName() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.creatorName.assertValue("Creator Name")
  }

  func testConfigureSharing() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.configureSharing.lastValue == (project, event))
  }

  func testError() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.failedToRetrieveEvent()
    self.vm.inputs.failedToUpdateSubscription()

    self.error.assertValues([
      "Failed to retrieve live stream event details",
      "Failed to update subscription"
      ])
  }

  func testIntroText() {
    let stream = LiveStreamEvent.template.stream
      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream .~ stream

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 0))
    XCTAssertTrue(self.introText.lastValue?.string == "Creator Name is live now")

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, replayAvailable: true, duration: 0))

    XCTAssertTrue(self.introText.lastValue?.string == "Creator Name was live right now")
  }

  func testLiveStreamTitle() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.liveStreamTitle.assertValue("Test Project")
  }

  func testLiveStreamParagraph() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.liveStreamParagraph.assertValue("Test LiveStreamEvent")
  }

  func testNumberOfPeopleWatchingText() {
    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 300)

    self.numberOfPeopleWatchingText.assertValue("300")
  }

  func testRetrieveEventInfo() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.vm.inputs.configureWith(project: project, event: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.fetchLiveStreamEvent()

    self.retrieveEventInfo.assertValue("123")
  }

  func testShowActivityIndicator() {
    let liveStream = Project.LiveStream.template
    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.vm.inputs.configureWith(project: project, event: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.fetchLiveStreamEvent()

    self.vm.inputs.setLiveStreamEvent(event: LiveStreamEvent.template)
    self.showActivityIndicator.assertValues([true, false])
  }

  func testSubscribe() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.subscribeButtonTapped()
    self.vm.inputs.setSubcribed(subscribed: true)
    self.showSubscribeButtonActivityIndicator.assertValues([false, true, false])
    self.subscribed.assertValues([false, true])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribed"])
    self.subscribeLabelText.assertValues(["Keep up with future live streams", ""])

    XCTAssertTrue(self.toggleSubscribe.values[0] == ("123", false))
  }

  func testSubscribeFailed() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.subscribeButtonTapped()
    self.vm.inputs.failedToUpdateSubscription()
    self.showSubscribeButtonActivityIndicator.assertValues([false, true, false, false])
    self.subscribed.assertValues([false, false])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribe"])
    self.subscribeLabelText.assertValues([
      "Keep up with future live streams",
      "Keep up with future live streams"
    ])
  }

  func testUpcomingIntroText() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.upcomingIntroText.lastValue?.string == "Upcoming with\nCreator Name")
  }
}

private func == (tuple1: (String, Bool), tuple2: (String, Bool)) -> Bool {
  return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
}

private func == (tuple1: (Project, LiveStreamEvent)?, tuple2: (Project, LiveStreamEvent)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}
