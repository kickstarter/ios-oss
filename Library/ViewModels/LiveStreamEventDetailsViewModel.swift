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
  func configureWith(project: Project, liveStreamEvent: LiveStreamEvent,
                     refTag: RefTag, presentedFromProject: Bool)

  /// Call when the goToProject button is tapped.
  func goToProjectButtonTapped()

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
  /// Emits when the subscribe button's activity indicator should animate
  var animateSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }

  /// Emits when the replay's available for text should be hidden
  var availableForLabelHidden: Signal<Bool, NoError> { get }

  /// Emits the text describing the replay's availability
  var availableForText: Signal<String, NoError> { get }

  /// Emits the url for the creator's avatar image
  var creatorAvatarUrl: Signal<URL?, NoError> { get }

  /// Emits a project and ref tag when we should navigate to the project
  var goToProject: Signal<(Project, RefTag), NoError> { get }

  /// Emits a boolean that determines if the project button container is hidden
  var goToProjectButtonContainerHidden: Signal<Bool, NoError> { get }

  /// Emits the title of the LiveStreamEvent
  var liveStreamTitle: Signal<String, NoError> { get }

  /// Emits the description of the LiveStreamEvent
  var liveStreamParagraph: Signal<String, NoError> { get }

  /// Emits the formatted number of people watching text
  var numberOfPeopleWatchingText: Signal<String, NoError> { get }

  /// Emits when the LoginToutViewController should open (login to subscribe)
  var openLoginToutViewController: Signal<(), NoError> { get }

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

  /// Emits the alpha value of the subscribe label
  var subscribeLabelAlpha: Signal<CGFloat, NoError> { get }

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

    let initialEvent = configData.map { _, event, _, _ in event }

    let updatedEventFetch = initialEvent
      .switchMap { event -> SignalProducer<Event<LiveStreamEvent, LiveApiError>, NoError> in
        AppEnvironment.current.liveStreamService
          .fetchEvent(
            eventId: event.id,
            uid: AppEnvironment.current.currentUser?.id,
            liveAuthToken: AppEnvironment.current.currentUser?.liveAuthToken
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .prefix(value: event)
          .materialize()
    }

    let event = updatedEventFetch.values()

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
      .switchMap { event -> SignalProducer<Event<LiveStreamSubscribeEnvelope, LiveApiError>, NoError> in
        guard let userId = AppEnvironment.current.currentUser?.id else { return .empty }

        return AppEnvironment.current.liveStreamService.subscribeTo(
          eventId: event.id, uid: userId, isSubscribed: subscribedProperty.value
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let isSubscribedEventValues = isSubscribedEvent.values().map {
      return $0.success == .some(true)
        ? !subscribedProperty.value
        : subscribedProperty.value
    }

    subscribedProperty <~ Signal.merge(
      // Bind the API response values for subscribed
      isSubscribedEventValues,

      // Bind the initial subscribed value
      event.map { $0.user?.isSubscribed ?? false }
    )

    let subscribed = subscribedProperty.signal

    self.availableForLabelHidden = event.map { $0.liveNow }

    self.availableForText = event
      .map { event -> String? in
        guard let availableDate = AppEnvironment.current.calendar
          .date(byAdding: .day, value: 2, to: event.startDate)?.timeIntervalSince1970
          else { return nil }

        let (time, units) = Format.duration(secondsInUTC: availableDate, abbreviate: false)

        return Strings.Available_to_watch_for_time_more_units(time: time, units: units)
      }.skipNil()

    self.creatorAvatarUrl = event
      .map { URL(string: $0.creator.avatar) }

    self.openLoginToutViewController = self.subscribeButtonTappedProperty.signal
      .filter { AppEnvironment.current.currentUser == nil }

    self.creatorName = event.map { $0.creator.name }
    self.liveStreamTitle = event.map { $0.name }
    self.liveStreamParagraph = event.map { $0.description }

    self.subscribeButtonImage = subscribed.map {
      $0 ? "postcard-checkmark" : nil
    }

    self.subscribeLabelText = subscribed.map { _ in
      Strings.Keep_up_with_future_live_streams()
    }.take(first: 1)

    self.subscribeButtonText = subscribed.map {
      $0 ? Strings.Subscribed() : Strings.Subscribe()
    }

    self.goToProject = configData
      .takeWhen(self.goToProjectButtonTappedProperty.signal)
      .map { project, liveStreamEvent, _, _ in
        (project, liveStreamEvent.liveNow ? .liveStream : .liveStreamReplay)
    }

    self.showErrorAlert = isSubscribedEvent
      .filter { $0.error != nil }
      .mapConst(Strings.Failed_to_update_subscription())

    self.animateSubscribeButtonActivityIndicator = Signal.merge(
      initialEvent.mapConst(true),
      updatedEventFetch.values().mapConst(false),
      updatedEventFetch.filter { $0.isTerminating }.mapConst(false),
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

    self.subscribeLabelAlpha = self.subscribeLabelHidden.map { $0 ? 0 : 1 }

    self.numberOfPeopleWatchingText = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst("0"),
      self.numberOfPeopleWatchingProperty.signal.skipNil().map { Format.wholeNumber($0) }
      )

    self.subscribeButtonAccessibilityHint = subscribed
      .map { isSubscribed in
        isSubscribed
          ? Strings.Unsubscribes_from_upcoming_lives_streams()
          : Strings.Subscribes_to_upcoming_lives_streams()
    }

    self.subscribeButtonAccessibilityLabel = subscribed
      .map { $0 ? Strings.Unsubscribe() : Strings.Subscribe() }

    self.goToProjectButtonContainerHidden = configData.map { $0.3 }

    configData
      .takePairWhen(isSubscribedEventValues)
      .observeValues { configData, isSubscribed in
        AppEnvironment.current.koala.trackLiveStreamToggleSubscription(project: configData.0,
                                                                       liveStreamEvent: configData.1,
                                                                       subscribed: isSubscribed
        )
    }
  }

  private let configData = MutableProperty<(Project, LiveStreamEvent, RefTag, Bool)?>(nil)
  public func configureWith(project: Project, liveStreamEvent: LiveStreamEvent, refTag: RefTag,
                            presentedFromProject: Bool) {
    self.configData.value = (project, liveStreamEvent, refTag, presentedFromProject)
  }

  private let goToProjectButtonTappedProperty = MutableProperty()
  public func goToProjectButtonTapped() {
    self.goToProjectButtonTappedProperty.value = ()
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

  public let animateSubscribeButtonActivityIndicator: Signal<Bool, NoError>
  public let availableForLabelHidden: Signal<Bool, NoError>
  public let availableForText: Signal<String, NoError>
  public let creatorAvatarUrl: Signal<URL?, NoError>
  public let creatorName: Signal<String, NoError>
  public let goToProject: Signal<(Project, RefTag), NoError>
  public let goToProjectButtonContainerHidden: Signal<Bool, NoError>
  public let liveStreamTitle: Signal<String, NoError>
  public let liveStreamParagraph: Signal<String, NoError>
  public let numberOfPeopleWatchingText: Signal<String, NoError>
  public let openLoginToutViewController: Signal<(), NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let subscribeButtonAccessibilityHint: Signal<String, NoError>
  public let subscribeButtonAccessibilityLabel: Signal<String, NoError>
  public let subscribeButtonImage: Signal<String?, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeLabelAlpha: Signal<CGFloat, NoError>
  public let subscribeLabelHidden: Signal<Bool, NoError>
  public let subscribeLabelText: Signal<String, NoError>

  public var inputs: LiveStreamEventDetailsViewModelInputs { return self }
  public var outputs: LiveStreamEventDetailsViewModelOutputs { return self }
}
