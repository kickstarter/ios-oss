import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamEventDetailsViewModelTests: TestCase {
  private let vm: LiveStreamEventDetailsViewModelType = LiveStreamEventDetailsViewModel()

  private let animateSubscribeButtonActivityIndicator = TestObserver<Bool, NoError>()
  private let creatorAvatarUrl = TestObserver<String?, NoError>()
  private let liveStreamTitle = TestObserver<String, NoError>()
  private let liveStreamParagraph = TestObserver<String, NoError>()
  private let numberOfPeopleWatchingText = TestObserver<String, NoError>()
  private let openLoginToutViewController = TestObserver<(), NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let subscribeButtonAccessibilityHint = TestObserver<String, NoError>()
  private let subscribeButtonAccessibilityLabel = TestObserver<String, NoError>()
  private let subscribeButtonImage = TestObserver<String?, NoError>()
  private let subscribeButtonText = TestObserver<String, NoError>()
  private let subscribeLabelText = TestObserver<String, NoError>()
  private let subscribeLabelHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.creatorAvatarUrl.map { $0?.absoluteString }.observe(self.creatorAvatarUrl.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.liveStreamTitle.observe(self.liveStreamTitle.observer)
    self.vm.outputs.liveStreamParagraph.observe(self.liveStreamParagraph.observer)
    self.vm.outputs.numberOfPeopleWatchingText.observe(self.numberOfPeopleWatchingText.observer)
    self.vm.outputs.openLoginToutViewController.observe(self.openLoginToutViewController.observer)
    self.vm.outputs.animateSubscribeButtonActivityIndicator.observe(
      self.animateSubscribeButtonActivityIndicator.observer)
    self.vm.outputs.subscribeButtonAccessibilityHint.observe(self.subscribeButtonAccessibilityHint.observer)
    self.vm.outputs.subscribeButtonAccessibilityLabel.observe(self.subscribeButtonAccessibilityLabel.observer)
    self.vm.outputs.subscribeButtonText.observe(self.subscribeButtonText.observer)
    self.vm.outputs.subscribeButtonImage.observe(self.subscribeButtonImage.observer)
    self.vm.outputs.subscribeLabelText.observe(self.subscribeLabelText.observer)
    self.vm.outputs.subscribeLabelHidden.observe(self.subscribeLabelHidden.observer)
  }

  func testSubscribeButtonAccessibilityHint() {
    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.user .~ LiveStreamEvent.User(isSubscribed: false)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
    self.vm.inputs.viewDidLoad()

    self.subscribeButtonAccessibilityHint.assertValues(["Subscribes to upcoming live streams."])

    self.vm.inputs.subscribeButtonTapped()
    self.scheduler.advance()

    self.subscribeButtonAccessibilityHint.assertValues([
      "Subscribes to upcoming live streams.",
      "Subscribes to upcoming live streams.",
      "Unsubscribes from upcoming live streams."
      ])
  }

  func testSubscribeButtonAccessibilityLabel() {
    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.user .~ LiveStreamEvent.User(isSubscribed: false)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
    self.vm.inputs.viewDidLoad()

    self.subscribeButtonAccessibilityLabel.assertValues(["Subscribe"])

    self.vm.inputs.subscribeButtonTapped()
    self.scheduler.advance()

    self.subscribeButtonAccessibilityLabel.assertValues(["Subscribe", "Subscribe", "Unsubscribe"])
  }

  func testCreatorAvatarUrl() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.creator.avatar .~ "https://www.com/creator-avatar.jpg"

    self.creatorAvatarUrl.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
    self.vm.inputs.viewDidLoad()

    self.creatorAvatarUrl.assertValues(["https://www.com/creator-avatar.jpg"])
  }

  func testLiveStreamTitle() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.name .~ "Test Stream"

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
    self.vm.inputs.viewDidLoad()

    self.liveStreamTitle.assertValues(["Test Stream"])
  }

  func testLiveStreamParagraph() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.description .~ "Test LiveStreamEvent"

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
    self.vm.inputs.viewDidLoad()

    self.liveStreamParagraph.assertValues(["Test LiveStreamEvent"])
  }

  func testNumberOfPeopleWatchingText() {
    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 300)

    self.numberOfPeopleWatchingText.assertValues(["0", "300"])

    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 350)

    self.numberOfPeopleWatchingText.assertValues(["0", "300", "350"])
  }

  func testSubscribe_LoggedIn() {
    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.user .~ LiveStreamEvent.User(isSubscribed: false)
      |> LiveStreamEvent.lens.liveNow .~ true

    self.subscribeLabelText.assertValueCount(0)
    self.subscribeLabelHidden.assertValueCount(0)
    self.subscribeButtonText.assertValueCount(0)
    self.subscribeButtonImage.assertValueCount(0)
    self.animateSubscribeButtonActivityIndicator.assertValueCount(0)

    let apiService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))
    withEnvironment(liveStreamService: apiService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual([], self.trackingClient.events)
      XCTAssertEqual([], self.trackingClient.properties(forKey: "context", as: String.self))

      self.animateSubscribeButtonActivityIndicator.assertValues([false, true])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true])
      self.subscribeButtonText.assertValues(["Subscribe"])
      self.subscribeButtonImage.assertValues([nil])

      self.scheduler.advance()

      self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true, false])
      self.subscribeButtonText.assertValues(["Subscribe", "Subscribe"])
      self.subscribeButtonImage.assertValues([nil, nil])

      self.vm.inputs.subscribeButtonTapped()

      self.scheduler.advance()

      self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false, true, false])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true, false, true])
      self.subscribeButtonText.assertValues(["Subscribe", "Subscribe", "Subscribed"])
      self.subscribeButtonImage.assertValues([nil, nil, "postcard-checkmark"])
      XCTAssertEqual(["Confirmed KSR Live Subscribe Button"], self.trackingClient.events)
      XCTAssertEqual(["live_stream_live"], self.trackingClient.properties(forKey: "context", as: String.self))

      self.vm.inputs.subscribeButtonTapped()

      self.scheduler.advance()

      self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false, true, false, true,
                                                                 false])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true, false, true, false])
      self.subscribeButtonText.assertValues(["Subscribe", "Subscribe", "Subscribed", "Subscribe"])
      self.subscribeButtonImage.assertValues([nil, nil, "postcard-checkmark", nil])
      XCTAssertEqual(["Confirmed KSR Live Subscribe Button", "Confirmed KSR Live Unsubscribe Button"],
                     self.trackingClient.events)
      XCTAssertEqual(["live_stream_live", "live_stream_live"], self.trackingClient.properties(
        forKey: "context", as: String.self))

    }

    let subscribeFailedApiService = MockLiveStreamService(subscribeToResult: Result(error: .genericFailure))
    withEnvironment(liveStreamService: subscribeFailedApiService) {
      self.vm.inputs.subscribeButtonTapped()

      self.scheduler.advance()

      self.animateSubscribeButtonActivityIndicator.assertValues([
        false, true, false, true, false, true, false, true, false
      ])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true, false, true, false, true, false])
      self.subscribeButtonText.assertValues(["Subscribe", "Subscribe", "Subscribed", "Subscribe"])
      self.subscribeButtonImage.assertValues([nil, nil, "postcard-checkmark", nil])
      XCTAssertEqual(["Confirmed KSR Live Subscribe Button", "Confirmed KSR Live Unsubscribe Button"],
                     self.trackingClient.events)
      XCTAssertEqual(["live_stream_live", "live_stream_live"], self.trackingClient.properties(
        forKey: "context", as: String.self))
    }
  }

  func testSubscribe_LoginDuring() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.user .~ LiveStreamEvent.User(isSubscribed: false)

    self.animateSubscribeButtonActivityIndicator.assertValueCount(0)
    self.subscribeLabelText.assertValueCount(0)
    self.subscribeLabelHidden.assertValueCount(0)
    self.subscribeButtonText.assertValueCount(0)
    self.subscribeButtonImage.assertValueCount(0)
    self.openLoginToutViewController.assertValueCount(0)

    let apiService = MockLiveStreamService(fetchEventResult: Result(liveStreamEvent))
    withEnvironment(liveStreamService: apiService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.animateSubscribeButtonActivityIndicator.assertValues([false, true])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true])
      self.subscribeButtonText.assertValues(["Subscribe"])
      self.subscribeButtonImage.assertValues([nil])
      self.openLoginToutViewController.assertValueCount(0)

      self.scheduler.advance()

      self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true, false])
      self.subscribeButtonText.assertValues(["Subscribe", "Subscribe"])
      self.subscribeButtonImage.assertValues([nil, nil])
      self.openLoginToutViewController.assertValueCount(0)

      self.vm.inputs.subscribeButtonTapped()

      self.openLoginToutViewController.assertValueCount(1)

      AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))
      self.vm.inputs.userSessionStarted()

      self.scheduler.advance()

      self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false, true, false])
      self.subscribeLabelText.assertValues(["Keep up with future live streams"])
      self.subscribeLabelHidden.assertValues([false, true, false, true])
      self.subscribeButtonText.assertValues(["Subscribe", "Subscribe", "Subscribed"])
      self.subscribeButtonImage.assertValues([nil, nil, "postcard-checkmark"])
      self.openLoginToutViewController.assertValueCount(1)
    }
  }
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
