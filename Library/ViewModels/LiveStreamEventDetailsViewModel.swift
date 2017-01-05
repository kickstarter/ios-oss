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
  func fetchLiveStreamEvent()
  func liveStreamViewControllerStateChanged(state state: LiveStreamViewControllerState)
  func subscribeButtonTapped()
  func setLiveStreamEvent(event event: LiveStreamEvent)
  func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  func setSubcribed(subscribed subscribed: Bool)
  func viewDidLoad()
}

public protocol LiveStreamEventDetailsViewModelOutputs {
  var availableForText: Signal<String, NoError> { get }
  var creatorAvatarUrl: Signal<NSURL, NoError> { get }
  var creatorName: Signal<String, NoError> { get }
  var configureSharing: Signal<(Project, LiveStreamEvent), NoError> { get }
  var error: Signal<String, NoError> { get }
  var introText: Signal<NSAttributedString, NoError> { get }
  var liveStreamTitle: Signal<String, NoError> { get }
  var liveStreamParagraph: Signal<String, NoError> { get }
  var numberOfPeopleWatchingText: Signal<String, NoError> { get }
  var retrieveEventInfo: Signal<String, NoError> { get }
  var showActivityIndicator: Signal<Bool, NoError> { get }
  var showSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }
  var subscribeButtonText: Signal<String, NoError> { get }
  var subscribeButtonImage: Signal<UIImage?, NoError> { get }
  var subscribed: Signal<Bool, NoError> { get }
  var subscribeLabelText: Signal<String, NoError> { get }
  var toggleSubscribe: Signal<(String, Bool), NoError> { get }
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
        NSForegroundColorAttributeName : UIColor.whiteColor()
      ]
      let boldAttributes = [
        NSFontAttributeName: UIFont.ksr_headline(size: 13),
        NSForegroundColorAttributeName : UIColor.whiteColor()
      ]

      if case .live = state {
        let text = localizedString(
          key: "Creator_name_is_live_now",
          defaultValue: "<b>%{creator_name}</b> is live now",
          substitutions: ["creator_name" : event.creator.name]
        )

        return text.simpleHtmlAttributedString(
          base: baseAttributes,
          bold: boldAttributes
        )
      }

      if case .replay = state {
        let text = localizedString(
          key: "Creator_name_was_live_time_ago",
          defaultValue: "<b>%{creator_name}</b> was live %{time_ago}",
          substitutions: [
            "creator_name" : event.creator.name,
            "time_ago" : (Format.relative(secondsInUTC: event.stream.startDate.timeIntervalSince1970,
              abbreviate: true))
          ]
        )

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
        NSForegroundColorAttributeName : UIColor.ksr_navy_600,
        NSParagraphStyleAttributeName : paragraphStyle
      ]

      let boldAttributes = [
        NSFontAttributeName: UIFont.ksr_headline(size: 14),
        NSForegroundColorAttributeName : UIColor.ksr_navy_700,
        NSParagraphStyleAttributeName : paragraphStyle
      ]

      let text = localizedString(
        key: "Upcoming_with_creator_name",
        defaultValue: "Upcoming with<br/><b>%{creator_name}</b>",
        substitutions: ["creator_name" : event.creator.name]
      )

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

        return localizedString(
          key: "Available_to_watch_for_time_more_units",
          defaultValue: "Available to watch for %{time} more %{units}",
          substitutions: [
            "time" : time,
            "units" : units
          ]
        )
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
    ).map(first)

    self.subscribeButtonImage = self.subscribed.map {
      $0 ? UIImage(named: "postcard-checkmark") : nil
    }

    self.subscribeLabelText = self.subscribed.map {
      !$0 ? localizedString(
        key: "Keep_up_with_future_live_streams", defaultValue: "Keep up with future live streams"
      ) : ""
    }

    self.subscribeButtonText = self.subscribed.map {
      $0 ? localizedString(key: "Subscribed", defaultValue: "Subscribed") :
        localizedString(key: "Subscribe", defaultValue: "Subscribe")
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
    ).takeWhen(self.subscribeButtonTappedProperty.signal)

    self.numberOfPeopleWatchingText = self.numberOfPeopleWatchingProperty.signal.ignoreNil()
      .map { String($0) }

    self.error = Signal.merge(
      self.failedToRetrieveEventProperty.signal.map {
        localizedString(
          key: "Failed_to_retrieve_live_stream_event_details",
          defaultValue: "Failed to retrieve live stream event details")
      },
      self.failedToUpdateSubscriptionProperty.signal.map {
        localizedString(
          key: "Failed_to_update_subscription",
          defaultValue: "Failed to update subscription"
        )
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
  public let retrieveEventInfo: Signal<String, NoError>
  public let showActivityIndicator: Signal<Bool, NoError>
  public let showSubscribeButtonActivityIndicator: Signal<Bool, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeButtonImage: Signal<UIImage?, NoError>
  public let subscribed: Signal<Bool, NoError>
  public let subscribeLabelText: Signal<String, NoError>
  public let toggleSubscribe: Signal<(String, Bool), NoError>
  public let upcomingIntroText: Signal<NSAttributedString, NoError>

  public var inputs: LiveStreamEventDetailsViewModelInputs { return self }
  public var outputs: LiveStreamEventDetailsViewModelOutputs { return self }
}
