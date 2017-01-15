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

  private let animateActivityIndicator = TestObserver<Bool, NoError>()
  private let animateSubscribeButtonActivityIndicator = TestObserver<Bool, NoError>()
  private let availableForText = TestObserver<String, NoError>()
  private let creatorAvatarUrl = TestObserver<String?, NoError>()
  private let configureShareViewModelProject = TestObserver<Project, NoError>()
  private let configureShareViewModelEvent = TestObserver<LiveStreamEvent, NoError>()
  private let detailsStackViewHidden = TestObserver<Bool, NoError>()
  private let liveStreamTitle = TestObserver<String, NoError>()
  private let liveStreamParagraph = TestObserver<String, NoError>()
  private let numberOfPeopleWatchingText = TestObserver<String, NoError>()
  private let openLoginToutViewController = TestObserver<(), NoError>()
  private let shareButtonEnabled = TestObserver<Bool, NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let subscribeButtonText = TestObserver<String, NoError>()
  private let subscribeButtonImage = TestObserver<String?, NoError>()
  private let subscribeLabelText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.availableForText.observe(self.availableForText.observer)
    self.vm.outputs.creatorAvatarUrl.map { $0?.absoluteString }.observe(self.creatorAvatarUrl.observer)
    self.vm.outputs.configureShareViewModel.map(first).observe(self.configureShareViewModelProject.observer)
    self.vm.outputs.configureShareViewModel.map(second).observe(self.configureShareViewModelEvent.observer)
    self.vm.outputs.detailsStackViewHidden.observe(self.detailsStackViewHidden.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.liveStreamTitle.observe(self.liveStreamTitle.observer)
    self.vm.outputs.liveStreamParagraph.observe(self.liveStreamParagraph.observer)
    self.vm.outputs.numberOfPeopleWatchingText.observe(self.numberOfPeopleWatchingText.observer)
    self.vm.outputs.openLoginToutViewController.observe(self.openLoginToutViewController.observer)
    self.vm.outputs.animateActivityIndicator.observe(self.animateActivityIndicator.observer)
    self.vm.outputs.animateSubscribeButtonActivityIndicator.observe(
      self.animateSubscribeButtonActivityIndicator.observer)
    self.vm.outputs.shareButtonEnabled.observe(self.shareButtonEnabled.observer)
    self.vm.outputs.subscribeButtonText.observe(self.subscribeButtonText.observer)
    self.vm.outputs.subscribeButtonImage.observe(self.subscribeButtonImage.observer)
    self.vm.outputs.subscribeLabelText.observe(self.subscribeLabelText.observer)
  }

  func testAvailableForText() {
    let liveStream = .template
      |> Project.LiveStream.lens.id .~ 42
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.startDate .~ MockDate().date
      |> LiveStreamEvent.lens.id .~ liveStream.id

    self.availableForText.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project, liveStream: liveStream, event: event)

    self.availableForText.assertValue("Available to watch for 2 more days")
  }

  func testCreatorAvatarUrl() {
    let event = .template
      |> LiveStreamEvent.lens.creator.avatar .~ "https://www.com/creator-avatar.jpg"

    self.creatorAvatarUrl.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStream: .template, event: event)
    self.vm.inputs.viewDidLoad()

    self.creatorAvatarUrl.assertValues(["https://www.com/creator-avatar.jpg"])
  }

  func testConfigureShareViewModel_WithEvent() {
    let event = LiveStreamEvent.template
    let liveStream = .template
      |> Project.LiveStream.lens.id .~ event.id

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.configureShareViewModelProject.assertValueCount(0)
    self.configureShareViewModelEvent.assertValueCount(0)
    self.animateActivityIndicator.assertValueCount(0)
    self.shareButtonEnabled.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, liveStream: liveStream, event: event)
    self.vm.inputs.viewDidLoad()

    self.animateActivityIndicator.assertValues([false])

    self.configureShareViewModelProject.assertValues([project])
    self.configureShareViewModelEvent.assertValues([event])

    self.shareButtonEnabled.assertValues([true])
  }

  func testConfigureShareViewModel_WithoutEvent() {
    let event = LiveStreamEvent.template
    let liveStream = .template
      |> Project.LiveStream.lens.id .~ event.id

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.configureShareViewModelProject.assertValueCount(0)
    self.configureShareViewModelEvent.assertValueCount(0)
    self.animateActivityIndicator.assertValueCount(0)
    self.shareButtonEnabled.assertValueCount(0)

    withEnvironment(liveStreamService: MockLiveStreamService(fetchEventResult: Result(event))) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(project: project, liveStream: liveStream, event: nil)

      self.animateActivityIndicator.assertValues([true])

      self.scheduler.advance()

      self.animateActivityIndicator.assertValues([true, false])

      self.configureShareViewModelProject.assertValues([project])
      self.configureShareViewModelEvent.assertValues([event])

      self.shareButtonEnabled.assertValues([true])
    }
  }

  func testShowErrorAlert() {
    let event = LiveStreamEvent.template
    let liveStream = .template
      |> Project.LiveStream.lens.id .~ event.id

    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.showErrorAlert.assertValueCount(0)
    self.animateActivityIndicator.assertValueCount(0)
    self.detailsStackViewHidden.assertValueCount(0)

    let apiService = MockLiveStreamService(fetchEventResult: Result(error: .genericFailure))
    withEnvironment(liveStreamService: apiService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(project: project, liveStream: liveStream, event: nil)

      self.animateActivityIndicator.assertValues([true])
      self.detailsStackViewHidden.assertValues([true])

      self.scheduler.advance()

      self.animateActivityIndicator.assertValues([true, false])
      self.detailsStackViewHidden.assertValues([true, false, true])
    }

    self.showErrorAlert.assertValues(["Failed to retrieve live stream event details"])
  }

  func testLiveStreamTitle() {
    let event = .template
      |> LiveStreamEvent.lens.stream.name .~ "Test Stream"

    self.vm.inputs.configureWith(project: .template, liveStream: .template, event: event)
    self.vm.inputs.viewDidLoad()

    self.liveStreamTitle.assertValues(["Test Stream"])
  }

  func testLiveStreamParagraph() {
    let event = .template
      |> LiveStreamEvent.lens.stream.description .~ "Test LiveStreamEvent"

    self.vm.inputs.configureWith(project: .template, liveStream: .template, event: event)
    self.vm.inputs.viewDidLoad()

    self.liveStreamParagraph.assertValues(["Test LiveStreamEvent"])
  }

  func testNumberOfPeopleWatchingText() {
    self.vm.inputs.configureWith(project: .template, liveStream: .template, event: .template)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 300)

    self.numberOfPeopleWatchingText.assertValues(["300"])

    self.vm.inputs.setNumberOfPeopleWatching(numberOfPeople: 350)

    self.numberOfPeopleWatchingText.assertValues(["300", "350"])
  }

  func testSubscribe_LoggedIn() {
    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    let event = .template
      |> LiveStreamEvent.lens.user.isSubscribed .~ false

    self.subscribeLabelText.assertValueCount(0)
    self.subscribeButtonText.assertValueCount(0)
    self.subscribeButtonImage.assertValueCount(0)
    self.animateSubscribeButtonActivityIndicator.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStream: .template, event: event)
    self.vm.inputs.viewDidLoad()

    self.animateSubscribeButtonActivityIndicator.assertValues([])

    self.subscribeLabelText.assertValues(["Keep up with future live streams"])
    self.subscribeButtonText.assertValues(["Subscribe"])
    self.subscribeButtonImage.assertValues([nil])

    self.vm.inputs.subscribeButtonTapped()

    self.scheduler.advance()

    self.animateSubscribeButtonActivityIndicator.assertValues([true, false])

    self.subscribeLabelText.assertValues(["Keep up with future live streams", ""])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribed"])
    self.subscribeButtonImage.assertValues([nil, "postcard-checkmark"])

    self.vm.inputs.subscribeButtonTapped()

    self.scheduler.advance()

    self.animateSubscribeButtonActivityIndicator.assertValues([true, false, true, false])

    self.subscribeLabelText.assertValues([
      "Keep up with future live streams",
      "",
      "Keep up with future live streams"
      ])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribed", "Subscribe"])
    self.subscribeButtonImage.assertValues([nil, "postcard-checkmark", nil])

    let apiService = MockLiveStreamService(subscribeToResult: Result(error: .genericFailure))
    withEnvironment(liveStreamService: apiService) {
      self.vm.inputs.subscribeButtonTapped()

      self.scheduler.advance()
      self.animateSubscribeButtonActivityIndicator.assertValues(
        [true, false, true, false, true, false]
      )

      self.subscribeLabelText.assertValues([
        "Keep up with future live streams",
        "",
        "Keep up with future live streams"
        ])
      self.subscribeButtonText.assertValues(["Subscribe", "Subscribed", "Subscribe"])
      self.subscribeButtonImage.assertValues([nil, "postcard-checkmark", nil])
    }
  }

  func testSubscribe_LoginDuring() {
    let event = .template
      |> LiveStreamEvent.lens.user.isSubscribed .~ false

    self.subscribeLabelText.assertValueCount(0)
    self.subscribeButtonText.assertValueCount(0)
    self.subscribeButtonImage.assertValueCount(0)
    self.animateSubscribeButtonActivityIndicator.assertValueCount(0)
    self.openLoginToutViewController.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStream: .template, event: event)
    self.vm.inputs.viewDidLoad()

    self.animateSubscribeButtonActivityIndicator.assertValues([])

    self.subscribeLabelText.assertValues(["Keep up with future live streams"])
    self.subscribeButtonText.assertValues(["Subscribe"])
    self.subscribeButtonImage.assertValues([nil])
    self.openLoginToutViewController.assertValueCount(0)

    self.vm.inputs.subscribeButtonTapped()

    self.openLoginToutViewController.assertValueCount(1)

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()

    self.scheduler.advance()

    self.animateSubscribeButtonActivityIndicator.assertValues([true, false])

    self.subscribeLabelText.assertValues(["Keep up with future live streams", ""])
    self.subscribeButtonText.assertValues(["Subscribe", "Subscribed"])
    self.subscribeButtonImage.assertValues([nil, "postcard-checkmark"])
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
