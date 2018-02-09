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

  /// Called when the video playback state changes.
  func videoPlaybackStateChanged(state: LiveVideoPlaybackState)

  /// Call when the viewDidDisappear.
  func viewDidDisappear()

  /// Call when the viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamContainerViewModelOutputs {
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

  // swiftlint:disable cyclomatic_complexity
  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let initialEvent = configData.map { $0.1 }

    let updatedEventFetch = Signal.merge(
      initialEvent,
      initialEvent.takeWhen(self.userSessionStartedProperty.signal)
      )
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

    let project = configData.map { $0.0 }
    let refTag = configData.map { $0.2 }
    let presentedFromProject = configData.map { $0.3 }

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

    let firebase = updatedEventFetch.values()
      .filter { !didEndNormally(event: $0) }
      .filter { !isNonStarter(event: $0) }
      .map { $0.firebase }
      .skipNil()
      .take(first: 1)

    let greenRoomStatusEvent = firebase
      .map { $0.greenRoomPath }
      .flatMap { path in
        AppEnvironment.current.liveStreamService.greenRoomOffStatus(
          withPath: path
          )
          .materialize()
    }

    let greenRoomOffStatus = greenRoomStatusEvent.values()

    let startNumberOfPeopleWatchingProducer = Signal.zip(
      updatedEventFetch.values(),
      firebase
    )

    let numberOfPeopleWatchingEvent = startNumberOfPeopleWatchingProducer
      .filter { liveStreamEvent, _ in liveStreamEvent.liveNow }
      .map { liveStreamEvent, firebase in
        (liveStreamEvent.isScale.coalesceWith(false), firebase)
      }
      .flatMap { isScale, firebase in
        numberOfPeopleWatchingProducer(withFirebase: firebase, isScale: isScale)
          .materialize()
      }

    let numberOfPeopleWatchingTimeOutSignal = startNumberOfPeopleWatchingProducer
      .flatMap { _ in
        SignalProducer.timer(interval: .seconds(10), on: AppEnvironment.current.scheduler)
      }
      .take(until: numberOfPeopleWatchingEvent.values().ignoreValues())

    self.numberOfPeopleWatching = Signal.merge(
      numberOfPeopleWatchingEvent.values(),
      numberOfPeopleWatchingEvent.errors().mapConst(0)
    )

    let maxOpenTokViewers = updatedEventFetch.values()
      .map { $0.maxOpenTokViewers }
      .skipNil()

    let hlsUrlEvent = Signal.zip(
      updatedEventFetch.values(),
      firebase
      )
      .map { liveStreamEvent, firebase -> (String, String?)? in
        guard let hlsUrl = liveStreamEvent.hlsUrl else { return nil }
        return (hlsUrl, firebase.hlsUrlPath)
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

    let useHlsStream = Signal.merge(
      isMaxOpenTokViewersReached,
      updatedEventFetch.values()
        .map { event in event.isRtmp == .some(true) || didEndNormally(event: event) }
        .filter(isTrue),
      numberOfPeopleWatchingTimeOutSignal.mapConst(true)
      )
      .take(first: 1)

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

    let liveStreamEndedNormally = updatedEventFetch.values()
      .map(didEndNormally(event:))

    let observedGreenRoomOffOrInReplay = Signal.merge(
      greenRoomOffStatus.filter(isTrue),
      liveStreamEndedNormally.filter(isTrue)
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

    let replayState = liveStreamEndedNormally
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.skipNil())
      .filter { didEndNormally, playbackState in didEndNormally && !playbackState.isError }

    let liveState = updatedEventFetch.values()
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.skipNil())
      .filter { _, playbackState in
        switch playbackState {
        case .loading,
             .playing:
          return true
        case .error:
          return false
        }
      }
      .filter { event, playbackState in
        event.liveNow && !playbackState.isError
      }

    let nonStarterState = updatedEventFetch.values()
      .map { event in isNonStarter(event: event) }
      .filter(isTrue)

    let firebaseUserId = updatedEventFetch.values()
      .map { $0.firebase?.token }
      .flatMap { token in
        signInToFirebase(withCustomToken: token)
          .materialize()
    }

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

    let videoEnabled = self.videoPlaybackStateChangedProperty.signal.skipNil()
      .filter { $0.isPlaying }
      .map { state -> Bool in
        if case let .playing(videoEnabled) = state { return videoEnabled }
        return false
    }

    self.loaderStackViewHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      videoEnabled
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
      videoEnabled.map(negate),
      isLoading
      )
      .skipRepeats()

    let playbackError = self.videoPlaybackStateChangedProperty.signal.skipNil()
      .map { $0.error }
      .skipNil()
      .map { error -> String in
        switch error {
        case .sessionInterrupted: return Strings.The_live_stream_was_interrupted()
        case .failedToConnect:    return Strings.The_live_stream_failed_to_connect()
        }
    }

    let greenRoomErrorBeforeValue = greenRoomStatusEvent
      .map { $0.error != nil }
      .take(first: 1)
      .filter(isTrue)

    self.showErrorAlert = Signal.merge(
      eventFetchError,
      playbackError,
      greenRoomErrorBeforeValue.mapConst(Strings.The_live_stream_failed_to_connect())
    )

    let liveStateLoaderText = refTag
      .takeWhen(liveState)
      .map { refTag -> String in
        if refTag == .liveStreamCountdown { return Strings.The_live_stream_will_start_soon() }

        return Strings.Joining_the_live_stream()
    }

    self.loaderText = Signal.merge(
      liveStateLoaderText,
      greenRoomState.mapConst(Strings.The_live_stream_will_start_soon()),
      replayState.mapConst(Strings.The_replay_will_start_soon()),
      nonStarterState.mapConst(Strings.No_replay_is_available_for_this_live_stream()),
      self.viewDidLoadProperty.signal.mapConst(Strings.Loading()),
      self.showErrorAlert,
      videoEnabled.filter(isFalse).mapConst(localizedString(
        key: "Video_disabled_until_the_internet_connection_improves",
        defaultValue: "Video disabled until the internet connection improves"))
      )
      .skipRepeats()

    self.loaderActivityIndicatorAnimating = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      nonStarterState.map(negate),
      self.showErrorAlert.mapConst(false),
      isPlaying.map(negate)
      )
      .skipRepeats()

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
  // swiftlint:enable function_body_length
  // swiftlint:enable cyclomatic_complexity

  private typealias ConfigData = (Project, LiveStreamEvent, RefTag, Bool)
  private let configData = MutableProperty<ConfigData?>(nil)
  public func configureWith(project: Project,
                            liveStreamEvent: LiveStreamEvent,
                            refTag: RefTag,
                            presentedFromProject: Bool) {
    self.configData.value = (project, liveStreamEvent, refTag, presentedFromProject)
  }

  private let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let deviceOrientationDidChangeProperty = MutableProperty<UIInterfaceOrientation?>(nil)
  public func deviceOrientationDidChange(orientation: UIInterfaceOrientation) {
    self.deviceOrientationDidChangeProperty.value = orientation
  }

  private let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let videoPlaybackStateChangedProperty = MutableProperty<LiveVideoPlaybackState?>(nil)
  public func videoPlaybackStateChanged(state: LiveVideoPlaybackState) {
    self.videoPlaybackStateChangedProperty.value = state
  }

  private let viewDidDisappearProperty = MutableProperty(())
  public func viewDidDisappear() {
    self.viewDidDisappearProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // Required to limit the lifetime of the minutes watched tracking timer
  private let token = Lifetime.Token()

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

private func signInToFirebase(withCustomToken customToken: String?) -> SignalProducer<String, LiveApiError> {
  if let token = customToken {
    return AppEnvironment.current.liveStreamService.signInToFirebase(withCustomToken: token)
  }

  return AppEnvironment.current.liveStreamService.signInToFirebaseAnonymously()
}

private func numberOfPeopleWatchingProducer(withFirebase firebase: LiveStreamEvent.Firebase,
                                            isScale: Bool) -> SignalProducer<Int, LiveApiError> {
  if isScale {
    return AppEnvironment.current.liveStreamService
      .scaleNumberOfPeopleWatching(withPath: firebase.scaleNumberPeopleWatchingPath)
  }

  return AppEnvironment.current.liveStreamService
    .numberOfPeopleWatching(withPath: firebase.numberPeopleWatchingPath)
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
