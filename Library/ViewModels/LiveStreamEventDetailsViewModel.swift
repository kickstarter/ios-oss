import KsApi
import LiveStream
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude

public protocol LiveStreamEventDetailsViewModelType {
  var inputs: LiveStreamEventDetailsViewModelInputs { get }
  var outputs: LiveStreamEventDetailsViewModelOutputs { get }
}

public protocol LiveStreamEventDetailsViewModelInputs {
  /// Call with the Project, the specific LiveStream and LiveStreamEvent
  func configureWith(project: Project, liveStreamEvent: LiveStreamEvent)

  /// Called when the LiveStreamViewController's state changes
  func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState)

  /// Called when the subscribe button is tapped
  func subscribeButtonTapped()

  /// Called to set the number of people watching the live stream
  func setNumberOfPeopleWatching(numberOfPeople: Int)

  /// Called when the user session starts
  func userSessionStarted()

  /// Called when viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamEventDetailsViewModelOutputs {
  /// Emits when the main activity indicator should animate (when the event is being fetched)
  var animateActivityIndicator: Signal<Bool, NoError> { get }

  /// Emits when the subscribe button's activity indicator should animate
  var animateSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }

  /// Emits the url for the creator's avatar image
  var creatorAvatarUrl: Signal<URL?, NoError> { get }

  /// Emits with the Project and LiveStreamEvent for configuring the ShareViewModel
  var configureShareViewModel: Signal<(Project, LiveStreamEvent), NoError> { get }

  /// Emits when the details stack view should be hidden
  var detailsStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits the title of the LiveStreamEvent
  var liveStreamTitle: Signal<String, NoError> { get }

  /// Emits the description of the LiveStreamEvent
  var liveStreamParagraph: Signal<String, NoError> { get }

  /// Emits the formatted number of people watching text
  var numberOfPeopleWatchingText: Signal<String, NoError> { get }

  /// Emits when the LoginToutViewController should open (login to subscribe)
  var openLoginToutViewController: Signal<(), NoError> { get }

  /// Emits when the share button should be enabled
  var shareButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits when an error has occurred
  var showErrorAlert: Signal<String, NoError> { get }

  /// Emits the subscribe button's accessibility hint
  var subscribeButtonAccessibilityHint: Signal<String, NoError> { get }

  /// Emits the subscribe button's accessibility label
  var subscribeButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the subscribe button's image
  var subscribeButtonImage: Signal<String?, NoError> { get }

  /// Emits the subscribe button's title
  var subscribeButtonText: Signal<String, NoError> { get }

  /// Emits when the subscribe button should be hidden
  var subscribeLabelHidden: Signal<Bool, NoError> { get }

  /// Emits the subscribe label's text
  var subscribeLabelText: Signal<String, NoError> { get }
}

public final class LiveStreamEventDetailsViewModel: LiveStreamEventDetailsViewModelType,
  LiveStreamEventDetailsViewModelInputs, LiveStreamEventDetailsViewModelOutputs {

  //swiftlint:disable:next function_body_length
  public init () {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let project = configData.map(first)

    let event = configData.map(second)

    self.configureShareViewModel = Signal.combineLatest(project, event)

    self.shareButtonEnabled = self.configureShareViewModel.mapConst(true)

    let subscribedProperty = MutableProperty(false)

    let subscribeTappedOnLogin = Signal.combineLatest(
      self.subscribeButtonTappedProperty.signal,
      self.userSessionStartedProperty.signal
      )
      .take(first: 1)

    let subscribeIntent = Signal.merge(
      subscribeTappedOnLogin.ignoreValues(),
      self.subscribeButtonTappedProperty.signal.filter { AppEnvironment.current.currentUser != nil }
    )

    let isSubscribedEvent = event
      .takeWhen(subscribeIntent)
      .switchMap { event -> SignalProducer<Event<Bool, LiveApiError>, NoError> in
        guard let userId = AppEnvironment.current.currentUser?.id else { return .empty }

        return AppEnvironment.current.liveStreamService.subscribeTo(
          eventId: event.id, uid: userId, isSubscribed: subscribedProperty.value
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    subscribedProperty <~ Signal.merge(
      // Bind the API response values for subscribed
      isSubscribedEvent.values(),

      // Bind the initial subscribed value
      event.map { $0.user.isSubscribed }
    )

    let subscribed = subscribedProperty.signal

    self.creatorAvatarUrl = event
      .map { URL(string: $0.creator.avatar) }

    self.openLoginToutViewController = self.subscribeButtonTappedProperty.signal
      .filter { AppEnvironment.current.currentUser == nil }

    self.creatorName = event.map { $0.creator.name }
    self.liveStreamTitle = event.map { $0.stream.name }
    self.liveStreamParagraph = event.map { $0.stream.description }

    self.subscribeButtonImage = subscribed.map {
      $0 ? "postcard-checkmark" : nil
    }

    self.subscribeLabelText = subscribed.map { _ in
      Strings.Keep_up_with_future_live_streams()
    }.take(first: 1)

    self.subscribeButtonText = subscribed.map {
      $0 ? Strings.Subscribed() : Strings.Subscribe()
    }

    self.showErrorAlert = isSubscribedEvent
      .filter { $0.error != nil }
      .mapConst(Strings.Failed_to_update_subscription())

    //FIXME: is this needed now at all?
    self.animateActivityIndicator = event.mapConst(false)

    self.animateSubscribeButtonActivityIndicator = Signal.merge(
      subscribeIntent.filter { AppEnvironment.current.currentUser != nil }.mapConst(true),
      self.subscribeButtonTappedProperty.signal
        .filter { AppEnvironment.current.currentUser != nil }
        .mapConst(true),
      isSubscribedEvent.filter { $0.isTerminating }.mapConst(false)
    ).skipRepeats()

    self.subscribeLabelHidden = Signal.merge(
      Signal.combineLatest(self.animateSubscribeButtonActivityIndicator, subscribed).map { $0 || $1 },
      subscribed
    ).skipRepeats()

    self.detailsStackViewHidden = Signal.merge(
      self.showErrorAlert.mapConst(true),
      self.animateActivityIndicator
    ).skipRepeats()

    self.numberOfPeopleWatchingText = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst("0"),
      self.numberOfPeopleWatchingProperty.signal.skipNil().map { Format.wholeNumber($0) }
      )

    self.subscribeButtonAccessibilityHint = subscribed
      .map { isSubscribed in
        isSubscribed
          ? localizedString(key: "Unsubscribes_from_upcoming_lives_streams.",
                            defaultValue: "Unsubscribes from upcoming live streams.")
          : localizedString(key: "Subscribes_to_upcoming_lives_streams",
                            defaultValue: "Subscribes to upcoming live streams.")
    }

    self.subscribeButtonAccessibilityLabel = subscribed
      .map { isSubscribed in
        isSubscribed
          ? localizedString(key: "Unsubscribe", defaultValue: "Unsubscribe")
          : Strings.Subscribe()
    }

    configData
      .takePairWhen(isSubscribedEvent.values())
      .observeValues { configData, isSubscribed in
        AppEnvironment.current.koala.trackLiveStreamToggleSubscription(project: configData.0,
                                                                       liveStreamEvent: configData.1,
                                                                       subscribed: isSubscribed
        )
    }
  }

  private let configData = MutableProperty<(Project, LiveStreamEvent)?>(nil)
  public func configureWith(project: Project, liveStreamEvent: LiveStreamEvent) {
    self.configData.value = (project, liveStreamEvent)
  }

  private let liveStreamViewControllerStateChangedProperty =
    MutableProperty<LiveStreamViewControllerState?>(nil)
  public func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState) {
    self.liveStreamViewControllerStateChangedProperty.value = state
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  public func setNumberOfPeopleWatching(numberOfPeople: Int) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let subscribeButtonTappedProperty = MutableProperty()
  public func subscribeButtonTapped() {
    self.subscribeButtonTappedProperty.value = ()
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let animateActivityIndicator: Signal<Bool, NoError>
  public let animateSubscribeButtonActivityIndicator: Signal<Bool, NoError>
  public let creatorAvatarUrl: Signal<URL?, NoError>
  public let creatorName: Signal<String, NoError>
  public let configureShareViewModel: Signal<(Project, LiveStreamEvent), NoError>
  public let detailsStackViewHidden: Signal<Bool, NoError>
  public let liveStreamTitle: Signal<String, NoError>
  public let liveStreamParagraph: Signal<String, NoError>
  public let numberOfPeopleWatchingText: Signal<String, NoError>
  public let openLoginToutViewController: Signal<(), NoError>
  public let shareButtonEnabled: Signal<Bool, NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let subscribeButtonAccessibilityHint: Signal<String, NoError>
  public let subscribeButtonAccessibilityLabel: Signal<String, NoError>
  public let subscribeButtonImage: Signal<String?, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeLabelHidden: Signal<Bool, NoError>
  public let subscribeLabelText: Signal<String, NoError>

  public var inputs: LiveStreamEventDetailsViewModelInputs { return self }
  public var outputs: LiveStreamEventDetailsViewModelOutputs { return self }
}
