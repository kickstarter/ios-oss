import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

internal protocol LiveStreamViewModelType {
  var inputs: LiveStreamViewModelInputs { get }
  var outputs: LiveStreamViewModelOutputs { get }
}

internal protocol LiveStreamViewModelInputs {
  // FIXME: alphabetize
  // FIXME: add comments

  func configureWith(app app: FirebaseAppType, event: LiveStreamEvent)
  func setFirebaseDatabaseRef(ref ref: FirebaseDatabaseReferenceType)
  func setGreenRoomActive(active active: Bool)
  func setHLSUrl(hlsUrl: String)
  func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  func setOpenTokSessionConfig(sessionConfig sessionConfig: OpenTokSessionConfig)
  func setScaleNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  // FIXME: remove this
//  func forceUseHLS()
  // FIXME: can remove this?
  func setNow(now now: NSDate)
  func videoPlaybackStateChanged(state state: LiveVideoPlaybackState)
  func viewDidLoad()
}

internal protocol LiveStreamViewModelOutputs {
  // FIXME: add comments

  // FIXME: update outputs to described exactly what is happening, i.e. observedGreenRoomOffChange

  var createGreenRoomObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError> { get }
  var createHLSObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError> { get }
  var createNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError> { get }
  var createScaleNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError> { get }
  var createVideoViewController: Signal<LiveStreamType, NoError> { get }
  // FIXME: can remove?
  var error: Signal<LiveVideoPlaybackError, NoError> { get }
  // FIXME: rename output to better describe what the view should do
  var firebaseApp: Signal<FirebaseAppType, NoError> { get }
  // FIXME: remove all references of this
//  var firebaseDatabaseRef: Signal<FirebaseDatabaseReferenceType, NoError> { get }
  // FIXME: can remove?
  var greenRoomActive: Signal<Bool, NoError> { get }
  var isReplayState: Signal<Bool, NoError> { get }
  // FIXME: rename to `notifyDelegate...`
  var liveStreamViewControllerState: Signal<LiveStreamViewControllerState, NoError> { get }
  // FIXME: rename to notifyDelegate...
  var numberOfPeopleWatching: Signal<Int, NoError> { get }
  var removeVideoViewController: Signal<(), NoError> { get }
  // FIXME: can remove?
  var replayAvailable: Signal<Bool, NoError> { get }
}

internal final class LiveStreamViewModel: LiveStreamViewModelType, LiveStreamViewModelInputs,
  LiveStreamViewModelOutputs {

  //swiftlint:disable:next function_body_length
  init(scheduler: DateSchedulerType = QueueScheduler.mainQueueScheduler) {
    let configData = combineLatest(self.configData.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let firebaseApp = configData.map(first)
    let liveStreamEvent = configData.map(second)

    let maxOpenTokViewers = liveStreamEvent.map { $0.stream.maxOpenTokViewers }

    let everySecondTimer = self.viewDidLoadProperty.signal.flatMap { timer(1, onScheduler: scheduler) }

    let liveStreamEndedWithTimeout = combineLatest(liveStreamEvent, everySecondTimer)
      .map { event, _ in !event.stream.liveNow && !event.stream.hasReplay && isExpired(event: event) }

    let liveStreamEndedNormally = liveStreamEvent
      .map { event in
        !event.stream.liveNow
          && event.stream.hasReplay
          && event.stream.startDate.compare(NSDate()) == .OrderedAscending
    }

    // FIXME: needs tests to figure out logic
    self.isReplayState = Signal.merge(
      combineLatest(liveStreamEndedWithTimeout, liveStreamEndedNormally).map { $0 || $1 },
      liveStreamEndedNormally
    ).skipRepeats()

    self.replayAvailable = combineLatest(
      self.isReplayState,
      liveStreamEvent.map {
        $0.stream.hasReplay && $0.stream.replayUrl != nil
      }
    ).map { $0 && $1 }

    let maxOpenTokViewersReached = combineLatest(
      self.numberOfPeopleWatchingProperty.signal.ignoreNil(),
      maxOpenTokViewers
      )
      .map { $0 > $1 }
      .take(1)

    let forceHls = Signal.merge(
      self.viewDidLoadProperty.signal.delay(10, onScheduler: scheduler).mapConst(true),
      maxOpenTokViewersReached
      )
      .take(1)

    let useHlsStream = Signal.merge(
      forceHls,
      self.isReplayState.filter(isTrue),
      liveStreamEvent.filter { $0.stream.isRtmp }.mapConst(true)
      )
      .take(1)

    let liveHlsUrl = Signal.merge(
      liveStreamEvent.map { LiveStreamType.hlsStream(hlsStreamUrl: $0.stream.hlsUrl) },
      self.hlsUrlProperty.signal.ignoreNil().map(LiveStreamType.hlsStream)
      )
      .filterWhenLatestFrom(self.isReplayState, satisfies: isFalse)

    let replayHlsUrl = liveStreamEvent
      .map { $0.stream.replayUrl }
      .ignoreNil()
      .map(LiveStreamType.hlsStream)
      .filterWhenLatestFrom(self.isReplayState, satisfies: isTrue)

    let hlsStreamUrl = Signal.merge(liveHlsUrl, replayHlsUrl)

    let openTokSessionConfig = Signal.merge(
      liveStreamEvent.map {
        LiveStreamType.openTok(
          sessionConfig: OpenTokSessionConfig(
            apiKey: $0.openTok.appId, sessionId: $0.openTok.sessionId, token: $0.openTok.token
          )
        )
      },
      self.openTokSessionConfigProperty.signal.ignoreNil().map {
        LiveStreamType.openTok(sessionConfig: $0)
      }
    )

    let liveStreamType = combineLatest(
      hlsStreamUrl,
      openTokSessionConfig,
      useHlsStream
    )
    .map { hlsStreamUrl, sessionConfig, useHlsStream in
      useHlsStream ? hlsStreamUrl : sessionConfig
    }
    .skipRepeats()

    self.greenRoomActive = combineLatest(
      self.greenRoomActiveProperty.signal,
      self.isReplayState
    )
    .map { $0 && !$1 }
    .skipRepeats()

    self.createVideoViewController = combineLatest(
      liveStreamType,
      self.greenRoomActive.filter { !$0 }
      )
      .map(first)

    self.numberOfPeopleWatching = Signal.merge(
      self.numberOfPeopleWatchingProperty.signal.ignoreNil(),
      self.scaleNumberOfPeopleWatchingProperty.signal.ignoreNil()
    )

    self.firebaseApp = combineLatest(
      firebaseApp,
      self.viewDidLoadProperty.signal
      )
      .map(first)
      .take(1)

    self.createGreenRoomObservers = combineLatest(
      self.firebaseDatabaseRef.signal.ignoreNil(),
      liveStreamEvent
        .map { FirebaseRefConfig(ref: $0.firebase.greenRoomPath, orderBy: "") }
    ).take(1)

    self.createHLSObservers = combineLatest(
      self.firebaseDatabaseRef.signal.ignoreNil(),
      liveStreamEvent
        .map { FirebaseRefConfig(ref: $0.firebase.hlsUrlPath, orderBy: "") }
    ).take(1)

    /// Should never emit if stream isScale
    self.createNumberOfPeopleWatchingObservers = combineLatest(
      self.firebaseDatabaseRef.signal.ignoreNil(),
      liveStreamEvent.filter { !$0.stream.isScale }
        .map { FirebaseRefConfig(ref: $0.firebase.numberPeopleWatchingPath, orderBy: "") }
    ).take(1)

    /// Should never emit if stream !isScale
    self.createScaleNumberOfPeopleWatchingObservers = combineLatest(
      self.firebaseDatabaseRef.signal.ignoreNil(),
      liveStreamEvent.filter { $0.stream.isScale }
        .map { FirebaseRefConfig(ref: $0.firebase.scaleNumberPeopleWatchingPath, orderBy: "") }
    ).take(1)

    /// Remove existing video view controllers if there are subsequent calls to createVideoViewController
    /// or if the green room becomes active again
    self.removeVideoViewController = Signal.merge(
      self.createVideoViewController.skip(1).ignoreValues(),
      zip(self.createVideoViewController, self.greenRoomActive.filter { $0 }).ignoreValues()
    )

    self.error = self.videoPlaybackStateChangedProperty.signal.ignoreNil()
      .map { state -> LiveVideoPlaybackError? in
      if case let .error(error) = state { return error }

      return nil
    }.ignoreNil()

    self.liveStreamViewControllerState = Signal.merge(
      self.greenRoomActive.filter { $0 }.mapConst(.greenRoom),
      combineLatest(
        self.isReplayState.filter { $0 },
        self.replayAvailable,
        self.videoPlaybackStateChangedProperty.signal.ignoreNil()
        ).map {
          .replay(playbackState: $2, replayAvailable: $1, duration: 0)
      },
      combineLatest(
        self.isReplayState.filter { !$0 },
        self.videoPlaybackStateChangedProperty.signal.ignoreNil()
        ).map {
          .live(playbackState: $1, startTime: 0)
      },
      self.error.map { .error(error: $0) }
    )
  }

  private let configData = MutableProperty<(FirebaseAppType, LiveStreamEvent)?>(nil)
  internal func configureWith(app app: FirebaseAppType, event: LiveStreamEvent) {
    self.configData.value = (app, event)
  }

  private let configureFirebaseDatabaseRefProperty = MutableProperty<FirebaseDatabaseReferenceType?>(nil)
  internal func configureFirebaseDatabaseRef(ref ref: FirebaseDatabaseReferenceType) {
    self.configureFirebaseDatabaseRefProperty.value = ref
  }

  private let forceUseHLSProperty = MutableProperty()
  internal func forceUseHLS() {
    self.forceUseHLSProperty.value = ()
  }

  private let firebaseDatabaseRef = MutableProperty<FirebaseDatabaseReferenceType?>(nil)
  internal func setFirebaseDatabaseRef(ref ref: FirebaseDatabaseReferenceType) {
    self.firebaseDatabaseRef.value = ref
  }

  private let greenRoomActiveProperty = MutableProperty(true)
  internal func setGreenRoomActive(active active: Bool) {
    self.greenRoomActiveProperty.value = active
  }

  private let hlsUrlProperty = MutableProperty<String?>(nil)
  internal func setHLSUrl(hlsUrl: String) {
    self.hlsUrlProperty.value = hlsUrl
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  internal func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let openTokSessionConfigProperty = MutableProperty<OpenTokSessionConfig?>(nil)
  internal func setOpenTokSessionConfig(sessionConfig sessionConfig: OpenTokSessionConfig) {
    self.openTokSessionConfigProperty.value = sessionConfig
  }

  private let scaleNumberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  internal func setScaleNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int) {
    self.scaleNumberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let nowProperty = MutableProperty<NSDate?>(nil)
  internal func setNow(now now: NSDate) {
    self.nowProperty.value = now
  }

  private let videoPlaybackStateChangedProperty = MutableProperty<LiveVideoPlaybackState?>(nil)
  internal func videoPlaybackStateChanged(state state: LiveVideoPlaybackState) {
    self.videoPlaybackStateChangedProperty.value = state
  }

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let createGreenRoomObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>
  internal let createHLSObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>
  internal let createNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>
  internal let createScaleNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>
  internal let createVideoViewController: Signal<LiveStreamType, NoError>
  internal let error: Signal<LiveVideoPlaybackError, NoError>
  internal let firebaseApp: Signal<FirebaseAppType, NoError>
//  internal let firebaseDatabaseRef: Signal<FirebaseDatabaseReferenceType, NoError>
  internal let greenRoomActive: Signal<Bool, NoError>
  internal let isReplayState: Signal<Bool, NoError>
  internal let liveStreamViewControllerState: Signal<LiveStreamViewControllerState, NoError>
  internal let numberOfPeopleWatching: Signal<Int, NoError>
  internal let removeVideoViewController: Signal<(), NoError>
  internal let replayAvailable: Signal<Bool, NoError>

  internal var inputs: LiveStreamViewModelInputs { return self }
  internal var outputs: LiveStreamViewModelOutputs { return self }
}

private func isExpired(event event: LiveStreamEvent) -> Bool {
  return NSCalendar.currentCalendar()
    .components(.Minute, fromDate: event.stream.startDate, toDate: NSDate(), options: [])
    .minute > 15
}
