import KsApi
import LiveStream
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol LiveStreamEventDetailsViewModelType {
  var inputs: LiveStreamEventDetailsViewModelInputs { get }
  var outputs: LiveStreamEventDetailsViewModelOutputs { get }
}

public protocol LiveStreamEventDetailsViewModelInputs {
  func configureWith(project project: Project, event: LiveStreamEvent?)
  func failedToRetrieveEvent()
  func failedToUpdateSubscription()
  func liveStreamViewControllerStateChanged(state state: LiveStreamViewControllerState)
  func subscribeButtonTapped()
  func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  func viewDidLoad()
}

public protocol LiveStreamEventDetailsViewModelOutputs {
  var animateActivityIndicator: Signal<Bool, NoError> { get }
  var animateSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }
  var availableForText: Signal<String, NoError> { get }
  var creatorAvatarUrl: Signal<NSURL?, NoError> { get }
  var configureShareViewModel: Signal<(Project, LiveStreamEvent), NoError> { get }
  var showErrorAlert: Signal<String, NoError> { get }
  var liveStreamTitle: Signal<String, NoError> { get }
  var liveStreamParagraph: Signal<String, NoError> { get }
  // FIXME: support abbreviations of large numbers
  var numberOfPeopleWatchingText: Signal<String, NoError> { get }
  var shareButtonEnabled: Signal<Bool, NoError> { get }
  var subscribeButtonText: Signal<String, NoError> { get }
  var subscribeButtonImage: Signal<UIImage?, NoError> { get }
  var subscribeLabelText: Signal<String, NoError> { get }
}

public final class LiveStreamEventDetailsViewModel: LiveStreamEventDetailsViewModelType,
  LiveStreamEventDetailsViewModelInputs, LiveStreamEventDetailsViewModelOutputs {

  //swiftlint:disable function_body_length
  public init () {

    let configData = combineLatest(
      self.configData.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let event = configData
      .switchMap { project, optionalEvent in
        fetchEvent(forProject: project, event: optionalEvent)
          .demoteErrors()
    }

    let project = configData.map(first)

    self.configureShareViewModel = combineLatest(
      project,
      event
    )

    self.shareButtonEnabled = self.configureShareViewModel.mapConst(true)

    let subscribedProperty = MutableProperty(false)

    // Bind the API response values for subscribed
    subscribedProperty <~ event
      .takeWhen(self.subscribeButtonTappedProperty.signal)
      .switchMap { event -> SignalProducer<Bool, NoError> in
        guard let userId = AppEnvironment.current.currentUser?.id else { return .empty }

        return AppEnvironment.current.liveStreamService.subscribeTo(
          eventId: event.id, uid: userId, isSubscribed: !subscribedProperty.value
          )
          .demoteErrors()
    }

    // Bind the initial subscribed value
    subscribedProperty <~ event.map { $0.user.isSubscribed }

    let subscribed = subscribedProperty.signal

    self.availableForText = combineLatest(
      event,
      self.viewDidLoadProperty.signal)
      .map(first)
      .map { event -> String? in
        guard let availableDate = AppEnvironment.current.calendar
          .dateByAddingUnit(.Day, value: 2, toDate: event.stream.startDate,
            options: [])?.timeIntervalSince1970
          else { return nil }

        let (time, units) = Format.duration(secondsInUTC: availableDate, abbreviate: false)

        return Strings.Available_to_watch_for_time_more_units(time: time, units: units)
      }.ignoreNil()

    self.creatorAvatarUrl = event
      .map { NSURL(string: $0.creator.avatar) }

    self.creatorName = event.map { $0.creator.name }
    self.liveStreamTitle = event.map { $0.stream.projectName }
    self.liveStreamParagraph = event.map { $0.stream.description }

    self.subscribeButtonImage = subscribed.map {
      $0 ? UIImage(named: "postcard-checkmark") : nil
    }

    self.subscribeLabelText = subscribed.map {
      !$0 ? Strings.Keep_up_with_future_live_streams() : ""
    }

    self.subscribeButtonText = subscribed.map {
      $0 ? Strings.Subscribed() : Strings.Subscribe()
    }

    self.animateActivityIndicator = Signal.merge(
      configData.filter { _, event in event == nil }.mapConst(true),
      event.mapConst(false)
    )

    self.animateSubscribeButtonActivityIndicator = Signal.merge(
      subscribed.mapConst(false),
      self.failedToUpdateSubscriptionProperty.signal.mapConst(false),
      self.subscribeButtonTappedProperty.signal.mapConst(true)
    )

    self.numberOfPeopleWatchingText = self.numberOfPeopleWatchingProperty.signal.ignoreNil()
      .map { String($0) }

    self.showErrorAlert = Signal.merge(
      self.failedToRetrieveEventProperty.signal.map {
        Strings.Failed_to_retrieve_live_stream_event_details()
      },
      self.failedToUpdateSubscriptionProperty.signal.map {
        Strings.Failed_to_update_subscription()
      })
  }
  //swiftlint:enable function_body_length

  private let configData = MutableProperty<(Project, LiveStreamEvent?)?>(nil)
  public func configureWith(project project: Project, event: LiveStreamEvent?) {
    self.configData.value = (project, event)
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let failedToRetrieveEventProperty = MutableProperty()
  public func failedToRetrieveEvent() {
    self.failedToRetrieveEventProperty.value = ()
  }

  private let failedToUpdateSubscriptionProperty = MutableProperty()
  public func failedToUpdateSubscription() {
    self.failedToUpdateSubscriptionProperty.value = ()
  }

  private let liveStreamViewControllerStateChangedProperty =
    MutableProperty<LiveStreamViewControllerState?>(nil)
  public func liveStreamViewControllerStateChanged(state state: LiveStreamViewControllerState) {
    self.liveStreamViewControllerStateChangedProperty.value = state
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  public func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let subscribeButtonTappedProperty = MutableProperty()
  public func subscribeButtonTapped() {
    self.subscribeButtonTappedProperty.value = ()
  }

  public let animateActivityIndicator: Signal<Bool, NoError>
  public let animateSubscribeButtonActivityIndicator: Signal<Bool, NoError>
  public let availableForText: Signal<String, NoError>
  public let creatorAvatarUrl: Signal<NSURL?, NoError>
  public let creatorName: Signal<String, NoError>
  public let configureShareViewModel: Signal<(Project, LiveStreamEvent), NoError>
  public let liveStreamTitle: Signal<String, NoError>
  public let liveStreamParagraph: Signal<String, NoError>
  public let numberOfPeopleWatchingText: Signal<String, NoError>
  public let shareButtonEnabled: Signal<Bool, NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeButtonImage: Signal<UIImage?, NoError>
  public let subscribeLabelText: Signal<String, NoError>

  public var inputs: LiveStreamEventDetailsViewModelInputs { return self }
  public var outputs: LiveStreamEventDetailsViewModelOutputs { return self }
}

private func fetchEvent(forProject project: Project, event: LiveStreamEvent?) -> SignalProducer<LiveStreamEvent, LiveApiError> {

  if let event = event {
    return SignalProducer(value: event)

  }

  if let eventId = project.liveStreams.first?.id {
    return AppEnvironment.current.liveStreamService.fetchEvent(
      eventId: eventId, uid: AppEnvironment.current.currentUser?.id
      )
  }

  return .empty
}
