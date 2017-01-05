import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

internal protocol LiveStreamViewModelType {
  var inputs: LiveStreamViewModelInputs { get }
  var outputs: LiveStreamViewModelOutputs { get }
}

internal protocol LiveStreamViewModelInputs {
  func configureFirebaseApp(app app: FirebaseAppType)
  func configureFirebaseDatabaseRef(ref ref: FirebaseDatabaseRefType)
  func configureWith(event event: LiveStreamEvent)
  func setGreenRoomActive(active active: Bool)
  func setHLSUrl(hlsUrl: String)
  func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  func setOpenTokSessionConfig(sessionConfig sessionConfig: OpenTokSessionConfig)
  func setScaleNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  func forceUseHLS()
  func setNow(now now: NSDate)
  func videoPlaybackStateChanged(state state: LiveVideoPlaybackState)
  func viewDidLoad()
}

internal protocol LiveStreamViewModelOutputs {
  var createGreenRoomObservers: Signal<(FirebaseDatabaseRefType, FirebaseRefConfig), NoError> { get }
  var createHLSObservers: Signal<(FirebaseDatabaseRefType, FirebaseRefConfig), NoError> { get }
  var createNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseRefType,
    FirebaseRefConfig), NoError> { get }
  var createScaleNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseRefType,
    FirebaseRefConfig), NoError> { get }
  var createVideoViewController: Signal<LiveStreamType, NoError> { get }
  var error: Signal<LiveVideoPlaybackError, NoError> { get }
  var firebaseApp: Signal<FirebaseAppType, NoError> { get }
  var firebaseDatabaseRef: Signal<FirebaseDatabaseRefType, NoError> { get }
  var greenRoomActive: Signal<Bool, NoError> { get }
  var isReplayState: Signal<Bool, NoError> { get }
  var liveStreamViewControllerState: Signal<LiveStreamViewControllerState, NoError> { get }
  var numberOfPeopleWatching: Signal<Int, NoError> { get }
  var removeVideoViewController: Signal<(), NoError> { get }
  var replayAvailable: Signal<Bool, NoError> { get }
}

internal final class LiveStreamViewModel: LiveStreamViewModelType, LiveStreamViewModelInputs,
  LiveStreamViewModelOutputs {

  //swiftlint:disable function_body_length
  init() {
    let maxOpenTokViewers = Signal.merge(
      self.scaleNumberOfPeopleWatchingProperty.signal.ignoreNil(),
      self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.maxOpenTokViewers }
    )

    let liveStreamPastExpiry = combineLatest(
      self.liveStreamEventProperty.signal.ignoreNil().map {
        NSCalendar.currentCalendar()
          .components(.Minute, fromDate: $0.stream.startDate, toDate: NSDate(), options: []).minute
        }.map { $0 > 15 },
      self.nowProperty.signal.ignoreNil()
    ).map(first)

    let liveStreamEndedWithTimeout = combineLatest(
      self.liveStreamEventProperty.signal.ignoreNil().map { !$0.stream.liveNow },
      self.liveStreamEventProperty.signal.ignoreNil().map { !$0.stream.hasReplay },
      liveStreamPastExpiry
    ).map { $0 && $1 && $2 }

    let liveStreamEndedNormally = combineLatest(
      self.liveStreamEventProperty.signal.ignoreNil().map { !$0.stream.liveNow },
      self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.hasReplay },
      self.liveStreamEventProperty.signal.ignoreNil().map {
        $0.stream.startDate.earlierDate(NSDate()) == $0.stream.startDate }
    ).map { $0 && $1 && $2 }

    self.isReplayState = Signal.merge(
      combineLatest(liveStreamEndedWithTimeout, liveStreamEndedNormally).map { $0 || $1 },
      liveStreamEndedNormally
    ).skipRepeats()

    self.replayAvailable = combineLatest(
      self.isReplayState,
      self.liveStreamEventProperty.signal.ignoreNil().map {
        $0.stream.hasReplay && $0.stream.replayUrl != nil
      }
    ).map { $0 && $1 }

    let scaleNumberOfPeopleReached = combineLatest(
      self.numberOfPeopleWatchingProperty.signal.ignoreNil(),
      maxOpenTokViewers
      )
      .map { $0 > $1 }
      .take(1)

    let useHLSStream = Signal.merge(
      combineLatest(
        scaleNumberOfPeopleReached,
        self.isReplayState
      ).map { $0 || $1 },
      self.forceUseHLSProperty.signal.mapConst(true),
      self.isReplayState.filter { $0 },
      self.liveStreamEventProperty.signal.ignoreNil().filter { $0.stream.isRtmp }.mapConst(true)
    )

    let hlsStreamUrl = Signal.merge(
      Signal.merge(
        self.liveStreamEventProperty.signal.ignoreNil().map {
          LiveStreamType.hlsStream(hlsStreamUrl: $0.stream.hlsUrl)
        },
        self.hlsUrlProperty.signal.ignoreNil().map {
          LiveStreamType.hlsStream(hlsStreamUrl: $0)
        }
      ).filterWhenLatestFrom(self.isReplayState, satisfies: { !$0 }),
      self.liveStreamEventProperty.signal.ignoreNil()
        .map { $0.stream.replayUrl }
        .ignoreNil()
        .map { LiveStreamType.hlsStream(hlsStreamUrl: $0) }
        .filterWhenLatestFrom(self.isReplayState, satisfies: { $0 })
    )

    let openTokSessionConfig = Signal.merge(
      self.liveStreamEventProperty.signal.ignoreNil().map {
        LiveStreamType.openTok(sessionConfig: OpenTokSessionConfig(
          apiKey: $0.openTok.appId, sessionId: $0.openTok.sessionId, token: $0.openTok.token))
      },
      self.openTokSessionConfigProperty.signal.ignoreNil().map {
        LiveStreamType.openTok(sessionConfig: $0)
      }
    )

    let liveStreamType = combineLatest(
      hlsStreamUrl,
      openTokSessionConfig,
      useHLSStream
    )
    .map { $2 ? $0 : $1 }
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
      self.configureFirebaseAppProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)
      .take(1)

    self.firebaseDatabaseRef = self.configureFirebaseDatabaseRefProperty.signal.ignoreNil().take(1)

    self.createGreenRoomObservers = combineLatest(
      self.firebaseDatabaseRef,
      self.liveStreamEventProperty.signal.ignoreNil()
        .map { FirebaseRefConfig(ref: $0.firebase.greenRoomPath, orderBy: "") }
    ).take(1)

    self.createHLSObservers = combineLatest(
      self.firebaseDatabaseRef,
      self.liveStreamEventProperty.signal.ignoreNil()
        .map { FirebaseRefConfig(ref: $0.firebase.hlsUrlPath, orderBy: "") }
    ).take(1)

    /// Should never emit if stream isScale
    self.createNumberOfPeopleWatchingObservers = combineLatest(
      self.firebaseDatabaseRef,
      self.liveStreamEventProperty.signal.ignoreNil().filter { !$0.stream.isScale }
        .map { FirebaseRefConfig(ref: $0.firebase.numberPeopleWatchingPath, orderBy: "") }
    ).take(1)

    /// Should never emit if stream !isScale
    self.createScaleNumberOfPeopleWatchingObservers = combineLatest(
      self.firebaseDatabaseRef,
      self.liveStreamEventProperty.signal.ignoreNil().filter { $0.stream.isScale }
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
  //swiftlint:enable function_body_length

  private let configureFirebaseAppProperty = MutableProperty<FirebaseAppType?>(nil)
  internal func configureFirebaseApp(app app: FirebaseAppType) {
    self.configureFirebaseAppProperty.value = app
  }

  private let configureFirebaseDatabaseRefProperty = MutableProperty<FirebaseDatabaseRefType?>(nil)
  internal func configureFirebaseDatabaseRef(ref ref: FirebaseDatabaseRefType) {
    self.configureFirebaseDatabaseRefProperty.value = ref
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  internal func configureWith(event event: LiveStreamEvent) {
    self.liveStreamEventProperty.value = event
  }

  private let forceUseHLSProperty = MutableProperty()
  internal func forceUseHLS() {
    self.forceUseHLSProperty.value = ()
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

  internal let createGreenRoomObservers: Signal<(FirebaseDatabaseRefType, FirebaseRefConfig), NoError>
  internal let createHLSObservers: Signal<(FirebaseDatabaseRefType, FirebaseRefConfig), NoError>
  internal let createNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseRefType,
    FirebaseRefConfig), NoError>
  internal let createScaleNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseRefType,
    FirebaseRefConfig), NoError>
  internal let createVideoViewController: Signal<LiveStreamType, NoError>
  internal let error: Signal<LiveVideoPlaybackError, NoError>
  internal let firebaseApp: Signal<FirebaseAppType, NoError>
  internal let firebaseDatabaseRef: Signal<FirebaseDatabaseRefType, NoError>
  internal let greenRoomActive: Signal<Bool, NoError>
  internal let isReplayState: Signal<Bool, NoError>
  internal let liveStreamViewControllerState: Signal<LiveStreamViewControllerState, NoError>
  internal let numberOfPeopleWatching: Signal<Int, NoError>
  internal let removeVideoViewController: Signal<(), NoError>
  internal let replayAvailable: Signal<Bool, NoError>

  internal var inputs: LiveStreamViewModelInputs { return self }
  internal var outputs: LiveStreamViewModelOutputs { return self }
}
