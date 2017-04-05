//swiftlint:disable file_length
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

internal protocol LiveStreamViewModelType {
  var inputs: LiveStreamViewModelInputs { get }
  var outputs: LiveStreamViewModelOutputs { get }
}

internal protocol LiveStreamViewModelInputs {
  /// Call to set the Firebase app and LiveStreamEvent.
  func configureWith(liveStreamEvent: LiveStreamEvent)

  /// Call when the user session changes.
  func userSessionChanged(session: LiveStreamSession)

  /// Called when the video playback state changes.
  func videoPlaybackStateChanged(state: LiveVideoPlaybackState)

  /// Call when the viewDidLoad.
  func viewDidLoad()

  /// Call when the viewDidDisappear.
  func viewDidDisappear()
}

internal protocol LiveStreamViewModelOutputs {
  /// Create the video view controller based on the live stream type.
  var createVideoViewController: Signal<LiveStreamType, NoError> { get }

  /// Disable idle time so that the display does not sleep.
  var disableIdleTimer: Signal<Bool, NoError> { get }

  /// Emits when a live stream api error occurred.
  var notifyDelegateLiveStreamApiErrorOccurred: Signal<LiveApiError, NoError> { get }

  /// Notify the delegate of the number of people watching change.
  var notifyDelegateLiveStreamNumberOfPeopleWatchingChanged: Signal<Int, NoError> { get }

  /// Notify the delegate of the live stream view controller state change.
  var notifyDelegateLiveStreamViewControllerStateChanged: Signal<LiveStreamViewControllerState,
    NoError> { get }

  /// Remove the nested video view controller.
  var removeVideoViewController: Signal<(), NoError> { get }
}

internal final class LiveStreamViewModel: LiveStreamViewModelType, LiveStreamViewModelInputs,
  LiveStreamViewModelOutputs {

  //swiftlint:disable:next function_body_length
  init(liveStreamService: LiveStreamServiceProtocol,
       scheduler: DateScheduler = QueueScheduler.main) {

    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let liveStreamEvent = configData

    let didLiveStreamEndedNormally = liveStreamEvent
      .map(didEndNormally(event:))

    let createObservers = Signal.zip(
      didLiveStreamEndedNormally.filter(isFalse),
      liveStreamEvent.map(isNonStarter(event:)).filter(isFalse)
      )
      .ignoreValues()
      .take(first: 1)

    let greenRoomStatusEvent = Signal.combineLatest(
      liveStreamEvent,
      createObservers
      )
      .map(first)
      .map { $0.firebase?.greenRoomPath }
      .skipNil()
      .flatMap { path in
        liveStreamService.greenRoomOffStatus(
          withPath: path
        )
        .materialize()
      }

    let greenRoomOffStatus = greenRoomStatusEvent.values()
    let greenRoomErrors = greenRoomStatusEvent.errors()

    let numberOfPeopleWatchingEvent = Signal.combineLatest(
      liveStreamEvent,
      createObservers
      )
      .map(first)
      .filter { $0.isScale == .some(false) }
      .map { $0.firebase?.numberPeopleWatchingPath }
      .skipNil()
      .flatMap { path in
        liveStreamService.numberOfPeopleWatching(
          withPath: path
          )
          .materialize()
    }

    let scaleNumberOfPeopleWatchingEvent = Signal.combineLatest(
      liveStreamEvent,
      createObservers
      )
      .map(first)
      .filter { $0.isScale == .some(true) }
      .map { $0.firebase?.scaleNumberPeopleWatchingPath }
      .skipNil()
      .flatMap { path in
        liveStreamService.scaleNumberOfPeopleWatching(
          withPath: path
          )
          .materialize()
    }

    let numberOfPeopleWatchingErrors = Signal.merge(
      numberOfPeopleWatchingEvent.errors(),
      scaleNumberOfPeopleWatchingEvent.errors()
    )

    let numberOfPeopleWatching = Signal.merge(
      numberOfPeopleWatchingEvent.values(),
      scaleNumberOfPeopleWatchingEvent.values()
    )

    let maxOpenTokViewers = liveStreamEvent
      .map { $0.maxOpenTokViewers }
      .skipNil()

    let hlsUrlEvent = Signal.combineLatest(
      liveStreamEvent,
      createObservers
      )
      .map(first)
      .map { $0.firebase?.hlsUrlPath }
      .skipNil()
      .flatMap { path in
        liveStreamService.hlsUrl(
          withPath: path
          )
          .materialize()
    }

    let observedHlsUrlChanged = hlsUrlEvent.values()
    let observedHlsUrlErrors = hlsUrlEvent.errors()

    let isMaxOpenTokViewersReached = Signal.combineLatest(
      numberOfPeopleWatching,
      maxOpenTokViewers
      )
      .map { $0 > $1 }
      .take(first: 1)

    let useHlsStream = Signal.merge(
      isMaxOpenTokViewersReached,
      liveStreamEvent
        .map { event in event.isRtmp == .some(true) || didEndNormally(event: event) }
        .filter(isTrue)
      )
      .take(first: 1)
      .timeout(after: 10, raising: SomeError(), on: scheduler)
      .flatMapError { _ in SignalProducer<Bool, NoError>(value: true) }

    let liveHlsUrl = Signal.merge(
      liveStreamEvent
        .filter { $0.liveNow }
        .map { $0.hlsUrl }
        .skipNil()
        .map(LiveStreamType.hlsStream),
      observedHlsUrlChanged.map(LiveStreamType.hlsStream)
    )

    let replayHlsUrl = liveStreamEvent
      .filter(didEndNormally(event:))
      .map { $0.replayUrl }
      .skipNil()
      .map(LiveStreamType.hlsStream)

    let hlsStreamUrl = Signal.merge(liveHlsUrl, replayHlsUrl)

    let openTokSessionConfig = liveStreamEvent.map { $0.openTok }
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

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = numberOfPeopleWatching

    self.removeVideoViewController = self.createVideoViewController.take(first: 1)
      .sample(on: greenRoomOffStatus.filter(isFalse).ignoreValues())
      .ignoreValues()

    let greenRoomState = greenRoomOffStatus
      .filter(isFalse)
      .mapConst(LiveStreamViewControllerState.greenRoom)

    let replayState = didLiveStreamEndedNormally
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.skipNil())
      .filter { didEndNormally, playbackState in didEndNormally && !playbackState.isError }
      .map { _, playbackState in
        LiveStreamViewControllerState.replay(playbackState: playbackState, duration: 0)
    }

    let liveState = liveStreamEvent
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.skipNil())
      .filter { event, playbackState in
        event.liveNow && !playbackState.isError
      }
      .map { _, playbackState in
        LiveStreamViewControllerState.live(playbackState: playbackState, startTime: 0)
    }

    let errorState = self.videoPlaybackStateChangedProperty.signal.skipNil()
      .map { $0.error }
      .skipNil()
      .map(LiveStreamViewControllerState.error)

    let nonStarterOrLoadingState = liveStreamEvent
      .map { event in
        isNonStarter(event: event)
          ? LiveStreamViewControllerState.nonStarter
          : LiveStreamViewControllerState.loading
      }

    let signInAnonymouslyEvent = Signal.merge(
      liveStreamEvent.filter { $0.firebase?.token == nil }.ignoreValues(),
      self.userSessionProperty.signal.skipNil().filter { $0.isAnonymous }.ignoreValues()
      )
      .flatMap {
        liveStreamService.signInToFirebaseAnonymously()
          .materialize()
    }

    let signInWithCustomTokenEvent = Signal.merge(
      liveStreamEvent.map { $0.firebase?.token }.skipNil(),
      self.userSessionProperty.signal.skipNil()
        .map { session -> String? in
          if case let .loggedIn(token) = session { return token }
          return nil
        }
        .skipNil()
      )
      .flatMap {
        liveStreamService.signInToFirebase(withCustomToken: $0)
          .materialize()
    }

    let firebaseUserId = Signal.merge(
      signInAnonymouslyEvent.values(),
      signInWithCustomTokenEvent.values()
    )

    let incrementNumberOfPeopleWatchingEvent = Signal.combineLatest(
      liveStreamEvent.map { $0.firebase?.numberPeopleWatchingPath }.skipNil(),
      firebaseUserId
      )
      .map { "\($0)/\($1)" }
      .switchMap { path in
        liveStreamService.incrementNumberOfPeopleWatching(
          withPath: path
          )
          .materialize()
    }

    incrementNumberOfPeopleWatchingEvent
      .values()
      // Observation here is purely to keep the above producer alive
      .observeValues { _ in }

    let signInErrors = Signal.merge(signInAnonymouslyEvent.errors(), signInWithCustomTokenEvent.errors())
    let incrementNumberOfPeopleWatchingErrors = incrementNumberOfPeopleWatchingEvent.errors()

    self.notifyDelegateLiveStreamApiErrorOccurred = Signal.merge(
      greenRoomErrors,
      numberOfPeopleWatchingErrors,
      observedHlsUrlErrors,
      signInErrors,
      incrementNumberOfPeopleWatchingErrors
    )

    self.notifyDelegateLiveStreamViewControllerStateChanged = Signal.merge(
      nonStarterOrLoadingState,
      errorState,
      greenRoomState,
      liveState,
      replayState
    )
  }

  private let configData = MutableProperty<LiveStreamEvent?>(nil)
  internal func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.configData.value = liveStreamEvent
  }

  private let userSessionProperty = MutableProperty<LiveStreamSession?>(nil)
  internal func userSessionChanged(session: LiveStreamSession) {
    self.userSessionProperty.value = session
  }

  private let videoPlaybackStateChangedProperty = MutableProperty<LiveVideoPlaybackState?>(nil)
  internal func videoPlaybackStateChanged(state: LiveVideoPlaybackState) {
    self.videoPlaybackStateChangedProperty.value = state
  }

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewDidDisappearProperty = MutableProperty()
  internal func viewDidDisappear() {
    self.viewDidDisappearProperty.value = ()
  }

  internal let createVideoViewController: Signal<LiveStreamType, NoError>
  internal let disableIdleTimer: Signal<Bool, NoError>
  internal let notifyDelegateLiveStreamApiErrorOccurred: Signal<LiveApiError, NoError>
  internal let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged: Signal<Int, NoError>
  internal let notifyDelegateLiveStreamViewControllerStateChanged: Signal<LiveStreamViewControllerState,
    NoError>
  internal let removeVideoViewController: Signal<(), NoError>

  internal var inputs: LiveStreamViewModelInputs { return self }
  internal var outputs: LiveStreamViewModelOutputs { return self }
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
