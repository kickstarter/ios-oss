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
  // FIXME: this could prob be removed and instead the VM use the config data to determine if it needs to retrieve event
  func fetchLiveStreamEvent()
  func liveStreamViewControllerStateChanged(state state: LiveStreamViewControllerState)
  func subscribeButtonTapped()
  // FIXME: rename to `retrievedLiveStreamEvent`
  func setLiveStreamEvent(event event: LiveStreamEvent)
  func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  func setSubcribed(subscribed subscribed: Bool)
  func viewDidLoad()
}

public protocol LiveStreamEventDetailsViewModelOutputs {
  var availableForText: Signal<String, NoError> { get }
  // FIXME: make this an optional NSURL?
  var creatorAvatarUrl: Signal<NSURL, NoError> { get }
  // FIXME: remove this output
  var creatorName: Signal<String, NoError> { get }
  // FIXME: rename to configureShareViewModel
  // FIXME: new output for `shareButtonEnabled`
  var configureSharing: Signal<(Project, LiveStreamEvent), NoError> { get }
  // FIXME: rename to `showErrorAlert`
  var error: Signal<String, NoError> { get }
  // FIXME: rename to creatorIntroText and move to the container vm
  var introText: Signal<NSAttributedString, NoError> { get }
  var liveStreamTitle: Signal<String, NoError> { get }
  var liveStreamParagraph: Signal<String, NoError> { get }
  // FIXME: support abbreviations of large numbers
  var numberOfPeopleWatchingText: Signal<String, NoError> { get }
  // FIXME: rename to `retrieveEventInfoWithEventIdAndUserId
  var retrieveEventInfo: Signal<(String, Int?), NoError> { get }
  // FIXME: do `animateActivityIndicator` instead and have it hide when no animating
  var showActivityIndicator: Signal<Bool, NoError> { get }
  // FIXME: use `animating...` instead
  var showSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }
  var subscribeButtonText: Signal<String, NoError> { get }
  var subscribeButtonImage: Signal<UIImage?, NoError> { get }
  // FIXME: could be removed?
  var subscribed: Signal<Bool, NoError> { get }
  var subscribeLabelText: Signal<String, NoError> { get }
  var toggleSubscribe: Signal<(String, Int, Bool), NoError> { get }
  // FIXME: move to the countdown vm
  var upcomingIntroText: Signal<NSAttributedString, NoError> { get }
}

public final class LiveStreamEventDetailsViewModel: LiveStreamEventDetailsViewModelType,
  LiveStreamEventDetailsViewModelInputs, LiveStreamEventDetailsViewModelOutputs {

  //swiftlint:disable function_body_length
  public init () {
    let event = combineLatest(
      self.liveStreamEventProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    let project = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    self.configureSharing = combineLatest(
      project,
      event
    )

    self.subscribed = Signal.merge(
      self.subscribedProperty.signal,
      event.map { $0.user.isSubscribed },
      combineLatest(
        event.map { $0.user.isSubscribed },
        self.failedToUpdateSubscriptionProperty.signal)
        .map(first)
    )

    self.introText = combineLatest(
      Signal.merge(
        self.liveStreamViewControllerStateChangedProperty.signal.ignoreNil(),
        project.mapConst(.loading)
      ),
      event
      )
      .observeForUI()
      .map { (state, event) -> NSAttributedString? in

      let baseAttributes = [
        NSFontAttributeName: UIFont.ksr_body(size: 13),
        NSForegroundColorAttributeName: UIColor.whiteColor()
      ]
      let boldAttributes = [
        NSFontAttributeName: UIFont.ksr_headline(size: 13),
        NSForegroundColorAttributeName: UIColor.whiteColor()
      ]

      if case .live = state {
        let text = Strings.Creator_name_is_live_now(creator_name: event.creator.name)

        return text.simpleHtmlAttributedString(
          base: baseAttributes,
          bold: boldAttributes
        )
      }

      if case .replay = state {
        let text = Strings.Creator_name_was_live_time_ago(
          creator_name: event.creator.name,
          time_ago: (Format.relative(secondsInUTC: event.stream.startDate.timeIntervalSince1970,
          abbreviate: true)))

        return text.simpleHtmlAttributedString(
          base: baseAttributes,
          bold: boldAttributes
        )
      }

      return NSAttributedString(string: "")
    }.ignoreNil()

    self.upcomingIntroText = event
      .observeForUI()
      .map { event -> NSAttributedString? in
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .Center

      let baseAttributes = [
        NSFontAttributeName: UIFont.ksr_subhead(size: 14),
        NSForegroundColorAttributeName: UIColor.ksr_navy_600,
        NSParagraphStyleAttributeName: paragraphStyle
      ]

      let boldAttributes = [
        NSFontAttributeName: UIFont.ksr_headline(size: 14),
        NSForegroundColorAttributeName: UIColor.ksr_navy_700,
        NSParagraphStyleAttributeName: paragraphStyle
      ]

      let text = Strings.Upcoming_with_creator_name(creator_name: event.creator.name)

      return text.simpleHtmlAttributedString(
        base: baseAttributes,
        bold: boldAttributes
      )
    }.ignoreNil()

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
      .ignoreNil()

    self.creatorName = event.map { $0.creator.name }
    self.liveStreamTitle = event.map { $0.stream.projectName }
    self.liveStreamParagraph = event.map { $0.stream.description }

    self.retrieveEventInfo = combineLatest(
      project.map { $0.liveStreams.first }.ignoreNil().map { $0.id },
      self.fetchLiveStreamEventProperty.signal
      )
      .map(first)
      .map {
        ($0, AppEnvironment.current.currentUser?.id)
    }

    self.subscribeButtonImage = self.subscribed.map {
      $0 ? UIImage(named: "postcard-checkmark") : nil
    }

    self.subscribeLabelText = self.subscribed.map {
      !$0 ? Strings.Keep_up_with_future_live_streams() : ""
    }

    self.subscribeButtonText = self.subscribed.map {
      $0 ? Strings.Subscribed() :
        Strings.Subscribe()
    }

    self.showActivityIndicator = Signal.merge(
      self.retrieveEventInfo.mapConst(true),
      event.mapConst(false)
    )

    self.showSubscribeButtonActivityIndicator = Signal.merge(
      self.subscribed.mapConst(false),
      self.failedToUpdateSubscriptionProperty.signal.mapConst(false),
      self.subscribeButtonTappedProperty.signal.mapConst(true)
    )

    self.toggleSubscribe = combineLatest(
      event.map { String($0.id) },
      self.subscribed
      )
      .takeWhen(self.subscribeButtonTappedProperty.signal)
      .map { eventId, subscribed -> (String, Int, Bool)? in
        guard let userId = AppEnvironment.current.currentUser?.id else { return nil }
        return (eventId, userId, subscribed)
      }
      .ignoreNil()

    self.numberOfPeopleWatchingText = self.numberOfPeopleWatchingProperty.signal.ignoreNil()
      .map { String($0) }

    self.error = Signal.merge(
      self.failedToRetrieveEventProperty.signal.map {
        Strings.Failed_to_retrieve_live_stream_event_details()
      },
      self.failedToUpdateSubscriptionProperty.signal.map {
        Strings.Failed_to_update_subscription()
      })
  }
  //swiftlint:enable function_body_length

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project, event: LiveStreamEvent?) {
    self.projectProperty.value = project
    self.liveStreamEventProperty.value = event
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

  private let fetchLiveStreamEventProperty = MutableProperty()
  public func fetchLiveStreamEvent() {
    self.fetchLiveStreamEventProperty.value = ()
  }

  private let liveStreamViewControllerStateChangedProperty =
    MutableProperty<LiveStreamViewControllerState?>(nil)
  public func liveStreamViewControllerStateChanged(state state: LiveStreamViewControllerState) {
    self.liveStreamViewControllerStateChangedProperty.value = state
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func setLiveStreamEvent(event event: LiveStreamEvent) {
    self.liveStreamEventProperty.value = event
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  public func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let subscribedProperty = MutableProperty(false)
  public func setSubcribed(subscribed subscribed: Bool) {
    self.subscribedProperty.value = subscribed
  }

  private let subscribeButtonTappedProperty = MutableProperty()
  public func subscribeButtonTapped() {
    self.subscribeButtonTappedProperty.value = ()
  }

  public let availableForText: Signal<String, NoError>
  public let creatorAvatarUrl: Signal<NSURL, NoError>
  public let creatorName: Signal<String, NoError>
  public let configureSharing: Signal<(Project, LiveStreamEvent), NoError>
  public let error: Signal<String, NoError>
  public let introText: Signal<NSAttributedString, NoError>
  public let liveStreamTitle: Signal<String, NoError>
  public let liveStreamParagraph: Signal<String, NoError>
  public let numberOfPeopleWatchingText: Signal<String, NoError>
  public let retrieveEventInfo: Signal<(String, Int?), NoError>
  public let showActivityIndicator: Signal<Bool, NoError>
  public let showSubscribeButtonActivityIndicator: Signal<Bool, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeButtonImage: Signal<UIImage?, NoError>
  public let subscribed: Signal<Bool, NoError>
  public let subscribeLabelText: Signal<String, NoError>
  public let toggleSubscribe: Signal<(String, Int, Bool), NoError>
  public let upcomingIntroText: Signal<NSAttributedString, NoError>

  public var inputs: LiveStreamEventDetailsViewModelInputs { return self }
  public var outputs: LiveStreamEventDetailsViewModelOutputs { return self }
}
