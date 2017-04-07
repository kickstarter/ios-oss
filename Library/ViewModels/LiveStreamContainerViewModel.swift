// swiftlint:disable file_length
import KsApi
import LiveStream
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude

public protocol LiveStreamContainerViewModelType {
  var inputs: LiveStreamContainerViewModelInputs { get }
  var outputs: LiveStreamContainerViewModelOutputs { get }
}

public protocol LiveStreamContainerViewModelInputs {
  /// Call with the Project, LiveStreamEvent, RefTag and whether presentation occurred from the project.
  func configureWith(project: Project,
                     liveStreamEvent: LiveStreamEvent,
                     refTag: RefTag,
                     presentedFromProject: Bool)

  /// Call when the close button is tapped
  func closeButtonTapped()

  /// Call when the device's orientation changed
  func deviceOrientationDidChange(orientation: UIInterfaceOrientation)

  /// Call when the user session starts.
  func userSessionStarted()

  /// Call when the user session end.
  func userSessionEnded()

  /// Called when the video playback state changes.
  func videoPlaybackStateChanged(state: LiveVideoPlaybackState)

  /// Call when the viewDidDisappear.
  func viewDidDisappear()

  /// Call when the viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamContainerViewModelOutputs {
  /// Emits whether the share bar button item should be added
  var addShareBarButtonItem: Signal<Bool, NoError> { get }

  /// Emits when the LiveStreamContainerPageViewController should be configured
  var configurePageViewController: Signal<(Project, LiveStreamEvent, RefTag, Bool), NoError> { get }

  /// Emits when the nav bar title view should be configured.
  var configureNavBarTitleView: Signal<LiveStreamEvent, NoError> { get }

  /// Create the video view controller based on the live stream type.
  var createVideoViewController: Signal<LiveStreamType, NoError> { get }

  /// Disable idle time so that the display does not sleep.
  var disableIdleTimer: Signal<Bool, NoError> { get }

  /// Emits when the view controller should dismiss
  var dismiss: Signal<(), NoError> { get }

  /// Emits when the loader activity indicator should animate
  var loaderActivityIndicatorAnimating: Signal<Bool, NoError> { get }

  /// Emits when the loader stack view should be hidden
  var loaderStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits the loader's text
  var loaderText: Signal<String, NoError> { get }

  /// Emits when the nav bar title view should be hidden.
  var navBarTitleViewHidden: Signal<Bool, NoError> { get }

  /// Emits the number of people currently watching the live stream.
  var numberOfPeopleWatching: Signal<Int, NoError> { get }

  /// Emits the project's image url
  var projectImageUrl: Signal<URL?, NoError> { get }

  /// Remove the nested video view controller.
  var removeVideoViewController: Signal<(), NoError> { get }

  /// Emits when an error occurred
  var showErrorAlert: Signal<String, NoError> { get }

  /// Emits when the video view controller should be hidden (when loading or green room is active)
  var videoViewControllerHidden: Signal<Bool, NoError> { get }
}

public final class LiveStreamContainerViewModel: LiveStreamContainerViewModelType,
LiveStreamContainerViewModelInputs, LiveStreamContainerViewModelOutputs {

  //swiftlint:disable function_body_length
  //swiftlint:disable cyclomatic_complexity
  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let initialEvent = configData.map { $0.1 }

    let updatedEventFetch = initialEvent
      .switchMap { initialEvent -> SignalProducer<Event<LiveStreamEvent, LiveApiError>, NoError> in

        timer(interval: .seconds(5), on: AppEnvironment.current.scheduler)
          .prefix(value: Date())
          .flatMap { _ in
            AppEnvironment.current.liveStreamService
              .fetchEvent(
                eventId: initialEvent.id,
                uid: AppEnvironment.current.currentUser?.id,
                liveAuthToken: AppEnvironment.current.currentUser?.liveAuthToken
              )
              .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
              .materialize()
          }
          .filter { event in
            if initialEvent.liveNow && event.error == nil {
              return event.value?.liveNow == .some(true)
            }

            return true
          }
          .take(first: 1)
    }

    let project = configData.map { project, _, _, _ in project }
    let refTag = configData.map { _, _, refTag, _ in refTag }
    let presentedFromProject = configData.map { _, _, _, presentedFromProject in presentedFromProject }

    self.configurePageViewController = Signal.combineLatest(
      project, initialEvent, refTag, presentedFromProject
      )
      .map { project, event, refTag, presentedFromProject in (project, event, refTag, presentedFromProject) }

    let eventFetchError = updatedEventFetch.errors().map { _ in
      return Strings.The_live_stream_failed_to_connect()
    }

    self.configureNavBarTitleView = updatedEventFetch.values()
    self.navBarTitleViewHidden = Signal.merge(
      initialEvent.mapConst(true),
      updatedEventFetch.values().mapConst(false)
    )

    configData
      .takePairWhen(self.deviceOrientationDidChangeProperty.signal.skipNil())
      .observeValues { data, orientation in
        let (project, liveStream, _, _) = data
        AppEnvironment.current.koala.trackChangedLiveStreamOrientation(project: project,
                                                                       liveStreamEvent: liveStream,
                                                                       toOrientation: orientation)
    }

    let startEndTimes = Signal.zip(
      configData.map { _ in AppEnvironment.current.scheduler.currentDate.timeIntervalSince1970 },
      self.closeButtonTappedProperty.signal
        .map { _ in AppEnvironment.current.scheduler.currentDate.timeIntervalSince1970 }
    )

    self.addShareBarButtonItem = updatedEventFetch.values()
      .map { $0.liveNow }
      .map(negate)

    let didLiveStreamEndedNormally = updatedEventFetch.values()
      .map(didEndNormally(event:))

    let createObservers = Signal.zip(
      didLiveStreamEndedNormally.filter(isFalse),
      updatedEventFetch.values().map(isNonStarter(event:)).filter(isFalse)
      )
      .ignoreValues()
      .take(first: 1)

    let greenRoomStatusEvent = Signal.combineLatest(
      updatedEventFetch.values(),
      createObservers
      )
      .map(first)
      .map { $0.firebase?.greenRoomPath }
      .skipNil()
      .flatMap { path in
        AppEnvironment.current.liveStreamService.greenRoomOffStatus(
          withPath: path
          )
          .materialize()
    }

    let greenRoomOffStatus = greenRoomStatusEvent.values()
    let greenRoomErrors = greenRoomStatusEvent.errors()

    let numberOfPeopleWatchingEvent = Signal.combineLatest(
      updatedEventFetch.values(),
      createObservers
      )
      .map(first)
      .filter { $0.isScale == .some(false) }
      .map { $0.firebase?.numberPeopleWatchingPath }
      .skipNil()
      .flatMap { path in
        AppEnvironment.current.liveStreamService.numberOfPeopleWatching(
          withPath: path
          )
          .materialize()
    }

    let scaleNumberOfPeopleWatchingEvent = Signal.combineLatest(
      updatedEventFetch.values(),
      createObservers
      )
      .map(first)
      .filter { $0.isScale == .some(true) }
      .map { $0.firebase?.scaleNumberPeopleWatchingPath }
      .skipNil()
      .flatMap { path in
        AppEnvironment.current.liveStreamService.scaleNumberOfPeopleWatching(
          withPath: path
          )
          .materialize()
    }

    let numberOfPeopleWatchingErrors = Signal.merge(
      numberOfPeopleWatchingEvent.errors(),
      scaleNumberOfPeopleWatchingEvent.errors()
    )

    self.numberOfPeopleWatching = Signal.merge(
      numberOfPeopleWatchingEvent.values(),
      scaleNumberOfPeopleWatchingEvent.values()
    )

    let maxOpenTokViewers = updatedEventFetch.values()
      .map { $0.maxOpenTokViewers }
      .skipNil()

    let hlsUrlEvent = Signal.combineLatest(
      updatedEventFetch.values(),
      createObservers
      )
      .map(first)
      .map { liveStreamEvent -> (String, String?)? in
        guard let hlsUrl = liveStreamEvent.hlsUrl else { return nil }
        return (hlsUrl, liveStreamEvent.firebase?.hlsUrlPath)
      }
      .skipNil()
      .flatMap { hlsUrl, hlsUrlPath -> SignalProducer<Event<String, LiveApiError>, NoError> in
        guard let hlsUrlPath = hlsUrlPath else { return SignalProducer(value: hlsUrl).materialize() }

        return AppEnvironment.current.liveStreamService.hlsUrl(withPath: hlsUrlPath)
          .prefix(value: hlsUrl)
          .materialize()
    }

    let isMaxOpenTokViewersReached = Signal.combineLatest(
      self.numberOfPeopleWatching,
      maxOpenTokViewers
      )
      .map { $0 > $1 }
      .take(first: 1)

    //fixme: timeout not working in tests?
    let useHlsStream = Signal.merge(
      isMaxOpenTokViewersReached,
      updatedEventFetch.values()
        .map { event in event.isRtmp == .some(true) || didEndNormally(event: event) }
        .filter(isTrue)
      )
      .take(first: 1)
      .timeout(after: 10, raising: SomeError(), on: AppEnvironment.current.scheduler)
      .flatMapError { _ in SignalProducer<Bool, NoError>(value: true) }

    let replayHlsUrl = updatedEventFetch.values()
      .filter(didEndNormally(event:))
      .map { $0.replayUrl }
      .skipNil()
      .map(LiveStreamType.hlsStream)

    let liveHlsUrl = hlsUrlEvent.values()
      .map(LiveStreamType.hlsStream)

    let hlsStreamUrl = Signal.merge(liveHlsUrl, replayHlsUrl)

    let openTokSessionConfig = updatedEventFetch.values().map { $0.openTok }
      .skipNil()
      .map {
        LiveStreamType.openTok(
          sessionConfig: OpenTokSessionConfig(
            apiKey: $0.appId, sessionId: $0.sessionId, token: $0.token
          )
        )
    }

    let liveStreamType = Signal.merge(
      Signal.combineLatest(hlsStreamUrl, useHlsStream.filter(isTrue)).map(first),
      Signal.combineLatest(openTokSessionConfig, useHlsStream.filter(isFalse)).map(first)
      )
      .skipRepeats()

    let observedGreenRoomOffOrInReplay = Signal.merge(
      greenRoomOffStatus.filter(isTrue),
      didLiveStreamEndedNormally.filter(isTrue)
      )
      .ignoreValues()

    self.createVideoViewController = Signal.combineLatest(
      liveStreamType,
      observedGreenRoomOffOrInReplay
      )
      .map(first)

    self.disableIdleTimer = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      self.viewDidDisappearProperty.signal.mapConst(false)
    )

    self.removeVideoViewController = self.createVideoViewController.take(first: 1)
      .sample(on: greenRoomOffStatus.filter(isFalse).ignoreValues())
      .ignoreValues()

    let greenRoomState = greenRoomOffStatus
      .filter(isFalse)

    let replayState = didLiveStreamEndedNormally
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.skipNil())
      .filter { didEndNormally, playbackState in didEndNormally && !playbackState.isError }

    let liveState = updatedEventFetch.values()
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.skipNil())
      .filter { event, playbackState in
        event.liveNow && !playbackState.isError
      }

    let nonStarterState = updatedEventFetch.values()
      .map { event in isNonStarter(event: event) }
      .filter(isTrue)

    //fixme: below does not ouput anything but perhaps we want to test it?
    let signInAnonymouslyEvent = Signal.merge(
      updatedEventFetch.values().filter { $0.firebase?.token == nil }.ignoreValues(),
      self.userSessionStartedProperty.signal.filter { AppEnvironment.current.currentUser == nil }
        .ignoreValues()
      )
      .flatMap {
        AppEnvironment.current.liveStreamService.signInToFirebaseAnonymously()
          .materialize()
    }

    let signInWithCustomTokenEvent = Signal.merge(
      updatedEventFetch.values().map { $0.firebase?.token }.skipNil(),
      self.userSessionStartedProperty.signal.map { AppEnvironment.current.currentUser?.liveAuthToken }
        .skipNil()
      )
      .flatMap {
        AppEnvironment.current.liveStreamService.signInToFirebase(withCustomToken: $0)
          .materialize()
    }

    let firebaseUserId = Signal.merge(
      signInAnonymouslyEvent.values(),
      signInWithCustomTokenEvent.values()
    )

    let incrementNumberOfPeopleWatchingEvent = Signal.combineLatest(
      updatedEventFetch.values().map { $0.firebase?.numberPeopleWatchingPath }.skipNil(),
      firebaseUserId
      )
      .map { "\($0)/\($1)" }
      .switchMap { path in
        AppEnvironment.current.liveStreamService.incrementNumberOfPeopleWatching(
          withPath: path
          )
          .materialize()
    }

    incrementNumberOfPeopleWatchingEvent
      .values()
      // Observation here is purely to keep the above producer alive
      .observeValues { _ in }

    let isPlaying = self.videoPlaybackStateChangedProperty.signal.skipNil()
      .map { state -> Bool in
        switch state {
        case .playing:
          return true
        case .error,
             .loading:
          return false
        }
    }

    let isLoading = self.videoPlaybackStateChangedProperty.signal.skipNil()
      .map { state -> Bool in
        switch state {
        case .loading:
          return true
        case .playing,
             .error:
          return false
        }
    }

    self.loaderStackViewHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      isPlaying.filter(isTrue).take(first: 1)
    )

    self.projectImageUrl = project.flatMap { project in
      SignalProducer(value: URL(string: project.photo.full))
        .prefix(value: nil)
    }

    self.titleViewText = Signal.merge(
      liveState.mapConst(Strings.Live()),
      greenRoomState.mapConst(Strings.Starting_soon()),
      replayState.mapConst(Strings.Recorded_Live()),
      self.viewDidLoadProperty.signal.mapConst(Strings.Loading())
    )

    self.dismiss = self.closeButtonTappedProperty.signal

    let numberOfMinutesWatched = isPlaying
      .filter(isTrue)
      .flatMap { _ in timer(interval: .seconds(60), on: AppEnvironment.current.scheduler) }
      .mapConst(1)

    self.videoViewControllerHidden = Signal.merge(
      isPlaying.map(negate),
      isLoading
    ).skipRepeats()

    let playbackError = self.videoPlaybackStateChangedProperty.signal.skipNil()
      .map { $0.error }
      .skipNil()
      .map { error -> String in
        switch error {
        case .sessionInterrupted: return Strings.The_live_stream_was_interrupted()
        case .failedToConnect:    return Strings.The_live_stream_failed_to_connect()
        }
    }

    self.showErrorAlert = Signal.merge(
      eventFetchError,
      playbackError
    )

    self.loaderText = Signal.merge(
      liveState.mapConst(Strings.The_live_stream_will_start_soon()),
      greenRoomState.mapConst(Strings.The_live_stream_will_start_soon()),
      replayState.mapConst(Strings.The_replay_will_start_soon()),
      nonStarterState.mapConst(Strings.No_replay_is_available_for_this_live_stream()),
      self.viewDidLoadProperty.signal.mapConst(Strings.Loading()),
      self.showErrorAlert
    )

    self.loaderActivityIndicatorAnimating = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      nonStarterState.map(negate),
      self.showErrorAlert.mapConst(false)
    )

    Signal.combineLatest(configData, startEndTimes)
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeValues { (configData, startEndTimes) in
        let (project, liveStreamEvent, refTag, _) = configData
        let (startTime, endTime) = startEndTimes

        AppEnvironment.current.koala.trackClosedLiveStream(project: project,
                                                           liveStreamEvent: liveStreamEvent,
                                                           startTime: startTime,
                                                           endTime: endTime,
                                                           refTag: refTag)
    }

    configData
      .takePairWhen(numberOfMinutesWatched)
      .map { tuple, minute in (tuple.0, tuple.1, tuple.2, minute) }
      .take(during: Lifetime(self.token))
      .observeValues { project, liveStreamEvent, refTag, minute in
        AppEnvironment.current.koala.trackWatchedLiveStream(project: project,
                                                            liveStreamEvent: liveStreamEvent,
                                                            refTag: refTag,
                                                            duration: minute)
    }

    configData
      .observeValues { project, liveStreamEvent, refTag, _ in
        AppEnvironment.current.koala.trackViewedLiveStream(project: project,
                                                           liveStreamEvent: liveStreamEvent,
                                                           refTag: refTag)
    }
  }
  //swiftlint:enable function_body_length
  //swiftlint:enable cyclomatic_complexity

  private typealias ConfigData = (Project, LiveStreamEvent, RefTag, Bool)
  private let configData = MutableProperty<ConfigData?>(nil)
  public func configureWith(project: Project,
                            liveStreamEvent: LiveStreamEvent,
                            refTag: RefTag,
                            presentedFromProject: Bool) {
    self.configData.value = (project, liveStreamEvent, refTag, presentedFromProject)
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let deviceOrientationDidChangeProperty = MutableProperty<UIInterfaceOrientation?>(nil)
  public func deviceOrientationDidChange(orientation: UIInterfaceOrientation) {
    self.deviceOrientationDidChangeProperty.value = orientation
  }

  private let userSessionEndedProperty = MutableProperty()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let videoPlaybackStateChangedProperty = MutableProperty<LiveVideoPlaybackState?>(nil)
  public func videoPlaybackStateChanged(state: LiveVideoPlaybackState) {
    self.videoPlaybackStateChangedProperty.value = state
  }

  private let viewDidDisappearProperty = MutableProperty()
  public func viewDidDisappear() {
    self.viewDidDisappearProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // Required to limit the lifetime of the minutes watched tracking timer
  private let token = Lifetime.Token()

  public let addShareBarButtonItem: Signal<Bool, NoError>
  public let configurePageViewController: Signal<(Project, LiveStreamEvent, RefTag, Bool), NoError>
  public let configureNavBarTitleView: Signal<LiveStreamEvent, NoError>
  public let createVideoViewController: Signal<LiveStreamType, NoError>
  public let disableIdleTimer: Signal<Bool, NoError>
  public let dismiss: Signal<(), NoError>
  public let loaderActivityIndicatorAnimating: Signal<Bool, NoError>
  public let loaderStackViewHidden: Signal<Bool, NoError>
  public let loaderText: Signal<String, NoError>
  public let navBarTitleViewHidden: Signal<Bool, NoError>
  public let numberOfPeopleWatching: Signal<Int, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let removeVideoViewController: Signal<(), NoError>
  public let showErrorAlert: Signal<String, NoError>
  public let titleViewText: Signal<String, NoError>
  public let videoViewControllerHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamContainerViewModelInputs { return self }
  public var outputs: LiveStreamContainerViewModelOutputs { return self }
}

private func isNonStarter(event: LiveStreamEvent) -> Bool {
  return !event.liveNow
    && !event.definitelyHasReplay
    && startDateMoreThanFifteenMinutesAgo(event: event)
}

private func startDateMoreThanFifteenMinutesAgo(event: LiveStreamEvent) -> Bool {
  let minute = Calendar.current
    .dateComponents([.minute], from: event.startDate as Date, to: Date())
    .minute ?? 0
  return minute > 15
}

private func didEndNormally(event: LiveStreamEvent) -> Bool {
  return !event.liveNow && event.definitelyHasReplay
}
