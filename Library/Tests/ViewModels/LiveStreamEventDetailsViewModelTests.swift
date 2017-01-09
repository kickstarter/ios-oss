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

  private let animateActivityIndicator = TestObserver<Bool, NoError>()
  private let animateSubscribeButtonActivityIndicator = TestObserver<Bool, NoError>()
  private let availableForText = TestObserver<String, NoError>()
  private let creatorAvatarUrl = TestObserver<String?, NoError>()
  private let configureShareViewModelProject = TestObserver<Project, NoError>()
  private let configureShareViewModelEvent = TestObserver<LiveStreamEvent, NoError>()
  private let liveStreamTitle = TestObserver<String, NoError>()
  private let liveStreamParagraph = TestObserver<String, NoError>()
  private let numberOfPeopleWatchingText = TestObserver<String, NoError>()
  private let retrieveEventInfoEventId = TestObserver<String, NoError>()
  private let retrieveEventInfoUserId = TestObserver<Int?, NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let subscribeButtonText = TestObserver<String, NoError>()
  private let subscribeButtonImage = TestObserver<UIImage?, NoError>()
  private let subscribeLabelText = TestObserver<String, NoError>()
  private let toggleSubscribeEventId = TestObserver<String, NoError>()
  private let toggleSubscribeUserId = TestObserver<Int, NoError>()
  private let toggleSubscribeValue = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.availableForText.observe(self.availableForText.observer)
    self.vm.outputs.creatorAvatarUrl.map { $0?.absoluteString }.observe(self.creatorAvatarUrl.observer)
    self.vm.outputs.configureShareViewModel.map { $0.0 }.observe(self.configureShareViewModelProject.observer)
    self.vm.outputs.configureShareViewModel.map { $0.1 }.observe(self.configureShareViewModelEvent.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.liveStreamTitle.observe(self.liveStreamTitle.observer)
    self.vm.outputs.liveStreamParagraph.observe(self.liveStreamParagraph.observer)
    self.vm.outputs.numberOfPeopleWatchingText.observe(self.numberOfPeopleWatchingText.observer)
    self.vm.outputs.retrieveEventInfoWithEventIdAndUserId.map(first)
      .observe(self.retrieveEventInfoEventId.observer)
    self.vm.outputs.retrieveEventInfoWithEventIdAndUserId.map(second)
      .observe(self.retrieveEventInfoUserId.observer)
    self.vm.outputs.animateActivityIndicator.observe(self.animateActivityIndicator.observer)
    self.vm.outputs.animateSubscribeButtonActivityIndicator.observe(
      self.animateSubscribeButtonActivityIndicator.observer)
    self.vm.outputs.subscribeButtonText.observe(self.subscribeButtonText.observer)
    self.vm.outputs.subscribeButtonImage.observe(self.subscribeButtonImage.observer)
    self.vm.outputs.subscribeLabelText.observe(self.subscribeLabelText.observer)
    self.vm.outputs.toggleSubscribe.map(first).observe(self.toggleSubscribeEventId.observer)
    self.vm.outputs.toggleSubscribe.map(second).observe(self.toggleSubscribeUserId.observer)
    self.vm.outputs.toggleSubscribe.map(third).observe(self.toggleSubscribeValue.observer)
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

    self.creatorAvatarUrl.assertValues(["https://www.kickstarter.com/creator-avatar.jpg"])
  }

  func testConfigureSharing() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.configureShareViewModelProject.assertValues([project])
    self.configureShareViewModelEvent.assertValues([event])
  }

  func testError() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.failedToRetrieveEvent()
    self.vm.inputs.failedToUpdateSubscription()

    self.showErrorAlert.assertValues([
      "Failed to retrieve live stream event details",
      "Failed to update subscription"
      ])
  }

//  func testIntroText() {
//    let stream = LiveStreamEvent.template.stream
//      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
//    let project = Project.template
//    let event = LiveStreamEvent.template
//      |> LiveStreamEvent.lens.stream .~ stream
//
//    self.vm.inputs.configureWith(project: project, event: event)
//    self.vm.inputs.viewDidLoad()
//
//    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 0))
//    XCTAssertTrue(self.introText.lastValue?.string == "Creator Name is live now")
//
//    self.vm.inputs.liveStreamViewControllerStateChanged(
//      state: .replay(playbackState: .playing, duration: 0))
//
//    XCTAssertTrue(self.introText.lastValue?.string == "Creator Name was live right now")
//  }

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


  //FIXME: rewrite these tests

//  func testRetrieveEventInfo() {
//    let liveStream = Project.LiveStream.template
//    let project = Project.template
//      |> Project.lens.liveStreams .~ [liveStream]
//
//    self.vm.inputs.configureWith(project: project, event: nil)
//    self.vm.inputs.viewDidLoad()
//    self.vm.inputs.fetchLiveStreamEvent()
//
//    self.retrieveEventInfoEventId.assertValues(["123"])
//    self.retrieveEventInfoUserId.assertValues([nil])
//  }
//
//  func testShowActivityIndicator() {
//    let liveStream = Project.LiveStream.template
//    let project = Project.template
//      |> Project.lens.liveStreams .~ [liveStream]
//
//    self.vm.inputs.configureWith(project: project, event: nil)
//    self.vm.inputs.viewDidLoad()
//    self.vm.inputs.fetchLiveStreamEvent()
//
//    self.vm.inputs.setLiveStreamEvent(event: LiveStreamEvent.template)
//    self.showActivityIndicator.assertValues([true, false])
//  }

  func testSubscribe() {
    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.subscribeButtonTapped()
    self.vm.inputs.setSubcribed(subscribed: true)
    self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribed"])
    self.subscribeLabelText.assertValues(["Keep up with future live streams", ""])

    self.toggleSubscribeEventId.assertValues(["123"])
    self.toggleSubscribeUserId.assertValues([1])
    self.toggleSubscribeValue.assertValues([false])
  }

  func testSubscribeFailed() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.subscribeButtonTapped()
    self.vm.inputs.failedToUpdateSubscription()
    self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false, false])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribe"])
    self.subscribeLabelText.assertValues([
      "Keep up with future live streams",
      "Keep up with future live streams"
    ])
  }

//  func testUpcomingIntroText() {
//    let project = Project.template
//    let event = LiveStreamEvent.template
//
//    self.vm.inputs.configureWith(project: project, event: event)
//    self.vm.inputs.viewDidLoad()
//
//    XCTAssertTrue(self.upcomingIntroText.lastValue?.string == "Upcoming with\nCreator Name")
//  }
}

private func == (tuple1: (String, Int?), tuple2: (String, Int?)) -> Bool {
  return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
}

private func == (tuple1: (String, Int, Bool), tuple2: (String, Int, Bool)) -> Bool {
  return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
}

private func == (tuple1: (Project, LiveStreamEvent)?, tuple2: (Project, LiveStreamEvent)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}
