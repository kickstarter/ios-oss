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
  private let showErrorAlert = TestObserver<String, NoError>()
  private let subscribeButtonText = TestObserver<String, NoError>()
  private let subscribeButtonImage = TestObserver<UIImage?, NoError>()
  private let subscribeLabelText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.availableForText.observe(self.availableForText.observer)
    self.vm.outputs.creatorAvatarUrl.map { $0?.absoluteString }.observe(self.creatorAvatarUrl.observer)
    self.vm.outputs.configureShareViewModel.map(first).observe(self.configureShareViewModelProject.observer)
    self.vm.outputs.configureShareViewModel.map(second).observe(self.configureShareViewModelEvent.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.liveStreamTitle.observe(self.liveStreamTitle.observer)
    self.vm.outputs.liveStreamParagraph.observe(self.liveStreamParagraph.observer)
    self.vm.outputs.numberOfPeopleWatchingText.observe(self.numberOfPeopleWatchingText.observer)
    self.vm.outputs.animateActivityIndicator.observe(self.animateActivityIndicator.observer)
    self.vm.outputs.animateSubscribeButtonActivityIndicator.observe(
      self.animateSubscribeButtonActivityIndicator.observer)
    self.vm.outputs.subscribeButtonText.observe(self.subscribeButtonText.observer)
    self.vm.outputs.subscribeButtonImage.observe(self.subscribeButtonImage.observer)
    self.vm.outputs.subscribeLabelText.observe(self.subscribeLabelText.observer)
  }

  func testAvailableForText() {
    let stream = LiveStreamEvent.template.stream
      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream .~ stream

    self.availableForText.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.availableForText.assertValue("Available to watch for 2 more days")
  }

  func testCreatorAvatarUrl() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.creatorAvatarUrl.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.creatorAvatarUrl.assertValues(["https://www.kickstarter.com/creator-avatar.jpg"])
  }

  func testConfigureShareViewModel_WithEvent() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.animateActivityIndicator.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.animateActivityIndicator.assertValues([false])

    self.configureShareViewModelProject.assertValues([project])
    self.configureShareViewModelEvent.assertValues([event])
  }

  func testConfigureShareViewModel_WithoutEvent() {
    let event = LiveStreamEvent.template

    let project = Project.template
      |> Project.lens.liveStreams .~ [
        .template
          |> Project.LiveStream.lens.id .~ event.id
    ]

    self.animateActivityIndicator.assertValueCount(0)

    withEnvironment(liveStreamService: MockLiveStreamService(fetchEventResult: Result(event))) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(project: project, event: nil)

      self.animateActivityIndicator.assertValues([true])

      self.scheduler.advance()

      self.animateActivityIndicator.assertValues([true, false])

      self.configureShareViewModelProject.assertValues([project])
      self.configureShareViewModelEvent.assertValues([event])
    }
  }

  //FIXME: Update when demoteErrors() removed
  func testShowErrorAlert() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.showErrorAlert.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, event: event)

    self.vm.inputs.failedToRetrieveEvent()
    self.vm.inputs.failedToUpdateSubscription()

    self.showErrorAlert.assertValues([
      "Failed to retrieve live stream event details",
      "Failed to update subscription"
      ])
  }

  func testLiveStreamTitle() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.liveStreamTitle.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.liveStreamTitle.assertValue("Test Project")
  }

  func testLiveStreamParagraph() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.liveStreamParagraph.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.liveStreamParagraph.assertValue("Test LiveStreamEvent")
  }

  func testNumberOfPeopleWatchingText() {
    self.numberOfPeopleWatchingText.assertValueCount(0)

    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 300)

    self.numberOfPeopleWatchingText.assertValues(["300"])

    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 350)

    self.numberOfPeopleWatchingText.assertValues(["300", "350"])
  }

  func testSubscribe() {
    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.user.isSubscribed .~ false

    self.subscribeLabelText.assertValueCount(0)
    self.subscribeButtonText.assertValueCount(0)
    self.animateSubscribeButtonActivityIndicator.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.animateSubscribeButtonActivityIndicator.assertValues([false])

    self.subscribeLabelText.assertValues(["Keep up with future live streams"])
    self.subscribeButtonText.assertValues(["Subscribe"])

    self.vm.inputs.subscribeButtonTapped()

    self.scheduler.advance()

    self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false])

    self.subscribeLabelText.assertValues(["Keep up with future live streams", ""])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribed"])

    self.vm.inputs.subscribeButtonTapped()

    self.scheduler.advance()

    self.animateSubscribeButtonActivityIndicator.assertValues([false, true, false, true, false])

    self.subscribeLabelText.assertValues([
      "Keep up with future live streams",
      "",
      "Keep up with future live streams"
      ])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribed", "Subscribe"])

    withEnvironment(liveStreamService: MockLiveStreamService(
      subscribeToResult: Result(error: .genericFailure))) {
        self.vm.inputs.subscribeButtonTapped()

        self.scheduler.advance()
        self.animateSubscribeButtonActivityIndicator.assertValues(
          [false, true, false, true, false, true, false]
        )

        //FIXME: Fix duplicate text with skipRepeats() in VM when errors are correctly handled
        self.subscribeLabelText.assertValues([
          "Keep up with future live streams",
          "",
          "Keep up with future live streams",
          "Keep up with future live streams"
          ])
        self.subscribeButtonText.assertValues(["Subscribe", "Subscribed", "Subscribe", "Subscribe"])
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
