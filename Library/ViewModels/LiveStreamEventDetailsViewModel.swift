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
  func configureWith(project: Project, liveStream: Project.LiveStream, event: LiveStreamEvent?)
  func liveStreamViewControllerStateChanged(state: LiveStreamViewControllerState)
  func subscribeButtonTapped()
  func setNumberOfPeopleWatching(numberOfPeople: Int)
  func userSessionStarted()
  func viewDidLoad()
}

public protocol LiveStreamEventDetailsViewModelOutputs {
  var animateActivityIndicator: Signal<Bool, NoError> { get }
  var animateSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }
  var availableForText: Signal<String, NoError> { get }
  var creatorAvatarUrl: Signal<URL?, NoError> { get }
  var configureShareViewModel: Signal<(Project, LiveStreamEvent), NoError> { get }
  var detailsStackViewHidden: Signal<Bool, NoError> { get }
  var liveStreamTitle: Signal<String, NoError> { get }
  var liveStreamParagraph: Signal<String, NoError> { get }
  var numberOfPeopleWatchingText: Signal<String, NoError> { get }
  var openLoginToutViewController: Signal<(), NoError> { get }
  var retrievedLiveStreamEvent: Signal<LiveStreamEvent, NoError> { get }
  var shareButtonEnabled: Signal<Bool, NoError> { get }
  var showErrorAlert: Signal<String, NoError> { get }
  var subscribeButtonAccessibilityHint: Signal<String, NoError> { get }
  var subscribeButtonAccessibilityLabel: Signal<String, NoError> { get }
  var subscribeButtonImage: Signal<String?, NoError> { get }
  var subscribeButtonText: Signal<String, NoError> { get }
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

    let eventEvent = configData
      .switchMap { project, liveStream, optionalEvent in
        fetchEvent(forProject: project, liveStream: liveStream, event: optionalEvent)
          .materialize()
    }

    let event = eventEvent.values()

    self.retrievedLiveStreamEvent = event

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

    self.availableForText = event
      .map { event -> String? in
        guard let availableDate = AppEnvironment.current.calendar
          .date(byAdding: .day, value: 2, to: event.stream.startDate)?.timeIntervalSince1970
          else { return nil }

        let (time, units) = Format.duration(secondsInUTC: availableDate, abbreviate: false)

        return Strings.Available_to_watch_for_time_more_units(time: time, units: units)
      }.skipNil()

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

    self.subscribeLabelText = subscribed.map {
      !$0 ? Strings.Keep_up_with_future_live_streams() : ""
    }

    self.subscribeButtonText = subscribed.map {
      $0 ? Strings.Subscribed() : Strings.Subscribe()
    }

    self.showErrorAlert = Signal.merge(
      eventEvent.filter { $0.error != nil }.mapConst(Strings.Failed_to_retrieve_live_stream_event_details()),
      isSubscribedEvent.filter { $0.error != nil }.mapConst(Strings.Failed_to_update_subscription())
    )

    self.animateActivityIndicator = Signal.merge(
      configData.filter { _, _, event in event == nil }.mapConst(true),
      event.mapConst(false),
      eventEvent.filter { $0.isTerminating }.mapConst(false),
      self.showErrorAlert.mapConst(false)
    ).skipRepeats()

    self.animateSubscribeButtonActivityIndicator = Signal.merge(
      subscribeIntent.filter { AppEnvironment.current.currentUser != nil }.mapConst(true),
      self.subscribeButtonTappedProperty.signal
        .filter { AppEnvironment.current.currentUser != nil }
        .mapConst(true),
      isSubscribedEvent.filter { $0.isTerminating }.mapConst(false)
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
          : localizedString(key: "Subscribe", defaultValue: "Subscribe")
    }

    configData
      .takePairWhen(isSubscribedEvent.values())
      .observeValues { configData, isSubscribed in
        let (project, liveStream, _) = configData
        AppEnvironment.current.koala.trackLiveStreamToggleSubscription(project: project,
                                                                       liveStream: liveStream,
                                                                       subscribed: isSubscribed)
    }
  }

  private let configData = MutableProperty<(Project, Project.LiveStream, LiveStreamEvent?)?>(nil)
  public func configureWith(project: Project, liveStream: Project.LiveStream, event: LiveStreamEvent?) {
    self.configData.value = (project, liveStream, event)
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
  public let availableForText: Signal<String, NoError>
  public let creatorAvatarUrl: Signal<URL?, NoError>
  public let creatorName: Signal<String, NoError>
  public let configureShareViewModel: Signal<(Project, LiveStreamEvent), NoError>
  public let detailsStackViewHidden: Signal<Bool, NoError>
  public let liveStreamTitle: Signal<String, NoError>
  public let liveStreamParagraph: Signal<String, NoError>
  public let numberOfPeopleWatchingText: Signal<String, NoError>
  public let openLoginToutViewController: Signal<(), NoError>
  public let retrievedLiveStreamEvent: Signal<LiveStreamEvent, NoError>
  public let shareButtonEnabled: Signal<Bool, NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let subscribeButtonAccessibilityHint: Signal<String, NoError>
  public let subscribeButtonAccessibilityLabel: Signal<String, NoError>
  public let subscribeButtonImage: Signal<String?, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeLabelText: Signal<String, NoError>

  public var inputs: LiveStreamEventDetailsViewModelInputs { return self }
  public var outputs: LiveStreamEventDetailsViewModelOutputs { return self }
}

private func fetchEvent(forProject project: Project, liveStream: Project.LiveStream, event: LiveStreamEvent?)
  -> SignalProducer<LiveStreamEvent, LiveApiError> {

    if let event = event {
      return SignalProducer(value: event)
    }

    return AppEnvironment.current.liveStreamService.fetchEvent(
      eventId: liveStream.id, uid: AppEnvironment.current.currentUser?.id
      )
      .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
}
