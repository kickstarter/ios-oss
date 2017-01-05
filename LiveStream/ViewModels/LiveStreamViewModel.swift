import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

internal protocol LiveStreamViewModelType {
  var inputs: LiveStreamViewModelInputs { get }
  var outputs: LiveStreamViewModelOutputs { get }
}

internal protocol LiveStreamViewModelInputs {
  /// Call to set the Firebase app and LiveStreamEvent
  func configureWith(app app: FirebaseAppType, event: LiveStreamEvent)

  /// Called when the green room changes to active or inactive when a creator goes on/off live
  func observedGreenRoomActiveChanged(active active: Bool)

  /// Called when the HLS url for the stream changes
  func observedHlsUrlChanged(hlsUrl: String)

  /// Called when the number of people watching changes in a non-scale event
  func observedNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: Int)

  /// Called when the number of people watching changes in a scaled event
  func observedScaleNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: Int)

  /// Call to set the FirebaseDatabase reference after the app is set
  func setFirebaseDatabaseRef(ref ref: FirebaseDatabaseReferenceType)

  /// Called when the video playback state changes
  func videoPlaybackStateChanged(state state: LiveVideoPlaybackState)

  /// Call when the viewDidLoad
  func viewDidLoad()
}

internal protocol LiveStreamViewModelOutputs {
  /// Create the Firebase app and configure the database reference
  var createFirebaseAppAndConfigureDatabaseReference: Signal<FirebaseAppType, NoError> { get }

  /// Create green room Firebase observers
  var createGreenRoomObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError> { get }

  /// Create HLS url Firebase observers
  var createHLSObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError> { get }

  /// Create non-scale event number of people watching Firebase observers
  var createNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError> { get }

  /// Create scale event number of people watching Firebase observers
  var createScaleNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError> { get }

  /// Create the video view controller based on the live stream type
  var createVideoViewController: Signal<LiveStreamType, NoError> { get }

  /// Notify the delegate of the number of people watching change
  var notifyDelegateLiveStreamNumberOfPeopleWatchingChanged: Signal<Int, NoError> { get }

  /// Notify the delegate of the live stream view controller state change
  var notifyDelegateLiveStreamViewControllerStateChanged: Signal<LiveStreamViewControllerState,
    NoError> { get }

  /// Remove the nested video view controller
  var removeVideoViewController: Signal<(), NoError> { get }
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
    let isReplayState = Signal.merge(
      combineLatest(liveStreamEndedWithTimeout, liveStreamEndedNormally).map { $0 || $1 },
      liveStreamEndedNormally
    ).skipRepeats()

    let replayAvailable = combineLatest(
      isReplayState,
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
      isReplayState.filter(isTrue),
      liveStreamEvent.filter { $0.stream.isRtmp }.mapConst(true)
      )
      .take(1)

    let liveHlsUrl = Signal.merge(
      liveStreamEvent.map { LiveStreamType.hlsStream(hlsStreamUrl: $0.stream.hlsUrl) },
      self.hlsUrlProperty.signal.ignoreNil().map(LiveStreamType.hlsStream)
      )
      .filterWhenLatestFrom(isReplayState, satisfies: isFalse)

    let replayHlsUrl = liveStreamEvent
      .map { $0.stream.replayUrl }
      .ignoreNil()
      .map(LiveStreamType.hlsStream)
      .filterWhenLatestFrom(isReplayState, satisfies: isTrue)

    let hlsStreamUrl = Signal.merge(liveHlsUrl, replayHlsUrl)

    let openTokSessionConfig = liveStreamEvent.map {
      LiveStreamType.openTok(
        sessionConfig: OpenTokSessionConfig(
          apiKey: $0.openTok.appId, sessionId: $0.openTok.sessionId, token: $0.openTok.token
        )
      )
    }

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
      isReplayState
    )
    .map { $0 && !$1 }
    .skipRepeats()

    self.createVideoViewController = combineLatest(
      liveStreamType,
      self.greenRoomActive.filter { !$0 }
      )
      .map(first)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = Signal.merge(
      self.numberOfPeopleWatchingProperty.signal.ignoreNil(),
      self.scaleNumberOfPeopleWatchingProperty.signal.ignoreNil()
    )

    self.createFirebaseAppAndConfigureDatabaseReference = combineLatest(
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

    self.notifyDelegateLiveStreamViewControllerStateChanged = Signal.merge(
      self.greenRoomActive.filter { $0 }.mapConst(.greenRoom),
      combineLatest(
        isReplayState.filter { $0 },
        replayAvailable,
        self.videoPlaybackStateChangedProperty.signal.ignoreNil()
        ).map {
          .replay(playbackState: $2, replayAvailable: $1, duration: 0)
      },
      combineLatest(
        isReplayState.filter { !$0 },
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
  internal func observedGreenRoomActiveChanged(active active: Bool) {
    self.greenRoomActiveProperty.value = active
  }

  private let hlsUrlProperty = MutableProperty<String?>(nil)
  internal func observedHlsUrlChanged(hlsUrl: String) {
    self.hlsUrlProperty.value = hlsUrl
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  internal func observedNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: Int) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let scaleNumberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  internal func observedScaleNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: Int) {
    self.scaleNumberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let videoPlaybackStateChangedProperty = MutableProperty<LiveVideoPlaybackState?>(nil)
  internal func videoPlaybackStateChanged(state state: LiveVideoPlaybackState) {
    self.videoPlaybackStateChangedProperty.value = state
  }

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let createFirebaseAppAndConfigureDatabaseReference: Signal<FirebaseAppType, NoError>
  internal let createGreenRoomObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>
  internal let createHLSObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>
  internal let createNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>
  internal let createScaleNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>
  internal let createVideoViewController: Signal<LiveStreamType, NoError>
  internal let error: Signal<LiveVideoPlaybackError, NoError>
  internal let greenRoomActive: Signal<Bool, NoError>
  internal let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged: Signal<Int, NoError>
  internal let notifyDelegateLiveStreamViewControllerStateChanged: Signal<LiveStreamViewControllerState,
    NoError>
  internal let removeVideoViewController: Signal<(), NoError>

  internal var inputs: LiveStreamViewModelInputs { return self }
  internal var outputs: LiveStreamViewModelOutputs { return self }
}

private func isExpired(event event: LiveStreamEvent) -> Bool {
  return NSCalendar.currentCalendar()
    .components(.Minute, fromDate: event.stream.startDate, toDate: NSDate(), options: [])
    .minute > 15
}
