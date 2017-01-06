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
  func configureWith(app app: FirebaseAppType, databaseRef: FirebaseDatabaseReferenceType, event: LiveStreamEvent)

  /// Called when the green room changes to active or inactive when a creator goes on/off live, expects a Bool
  func observedGreenRoomOffChanged(off off: AnyObject?)

  /// Called when the HLS url for the stream changes, expects a String
  func observedHlsUrlChanged(hlsUrl hlsUrl: AnyObject?)

  /// Called when the number of people watching changes in a non-scale event, expects an NSDictionary
  func observedNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: AnyObject?)

  /// Called when the number of people watching changes in a scaled event, expects an Int
  func observedScaleNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: AnyObject?)

  /// Called when the video playback state changes
  func videoPlaybackStateChanged(state state: LiveVideoPlaybackState)

  /// Call when the viewDidLoad
  func viewDidLoad()
}

internal protocol LiveStreamViewModelOutputs {
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
    let databaseRef = configData.map(second)
    let liveStreamEvent = configData.map(third)

    let maxOpenTokViewers = liveStreamEvent.map { $0.stream.maxOpenTokViewers }

    let everySecondTimer = self.viewDidLoadProperty.signal.flatMap { timer(1, onScheduler: scheduler) }

    let liveStreamEndedWithTimeout = combineLatest(liveStreamEvent, everySecondTimer)
      .map { event, _ in
        !event.stream.liveNow
          && !event.stream.hasReplay
          && isExpired(event: event)
    }

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

    let observedNumberOfPeopleWatchingChanged = self.numberOfPeopleWatchingProperty.signal
      .map { $0 as? NSDictionary }
      .ignoreNil()
      .map { $0.allKeys.count }

    let observedScaleNumberOfPeopleWatchingChanged = self.scaleNumberOfPeopleWatchingProperty.signal
      .map { $0 as? Int }
      .ignoreNil()

    let observedHlsUrlChanged = self.hlsUrlProperty.signal.map { $0 as? String }.ignoreNil()

    let observedGreenRoomOffChanged = self.greenRoomOffProperty.signal.map { $0 as? Bool }.ignoreNil()

    let maxOpenTokViewersReached = combineLatest(
      observedNumberOfPeopleWatchingChanged,
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
      observedHlsUrlChanged.map(LiveStreamType.hlsStream)
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
      observedGreenRoomOffChanged.map(negate),
      isReplayState
    )
    .map { $0 && !$1 }
    .skipRepeats()

    self.createVideoViewController = combineLatest(
      liveStreamType,
      self.greenRoomActive.filter(isFalse)
      )
      .map(first)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = Signal.merge(
      observedNumberOfPeopleWatchingChanged,
      observedScaleNumberOfPeopleWatchingChanged
    )

    self.createGreenRoomObservers = zip(
      databaseRef,
      liveStreamEvent
        .map { FirebaseRefConfig(ref: $0.firebase.greenRoomPath, orderBy: "") }
    )

    self.createHLSObservers = zip(
      databaseRef,
      liveStreamEvent
        .map { FirebaseRefConfig(ref: $0.firebase.hlsUrlPath, orderBy: "") }
    )

    /// Should never emit if stream isScale
    self.createNumberOfPeopleWatchingObservers = zip(
      databaseRef,
      liveStreamEvent.filter { !$0.stream.isScale }
        .map { FirebaseRefConfig(ref: $0.firebase.numberPeopleWatchingPath, orderBy: "") }
    )

    /// Should never emit if stream !isScale
    self.createScaleNumberOfPeopleWatchingObservers = combineLatest(
      databaseRef,
      liveStreamEvent.filter { $0.stream.isScale }
        .map { FirebaseRefConfig(ref: $0.firebase.scaleNumberPeopleWatchingPath, orderBy: "") }
    )

    self.removeVideoViewController = self.greenRoomActive.filter(isTrue).ignoreValues()

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

  private let configData = MutableProperty<(FirebaseAppType, FirebaseDatabaseReferenceType, LiveStreamEvent)?>(nil)
  internal func configureWith(app app: FirebaseAppType, databaseRef: FirebaseDatabaseReferenceType, event: LiveStreamEvent) {
    self.configData.value = (app, databaseRef, event)
  }

  private let configureFirebaseDatabaseRefProperty = MutableProperty<FirebaseDatabaseReferenceType?>(nil)
  internal func configureFirebaseDatabaseRef(ref ref: FirebaseDatabaseReferenceType) {
    self.configureFirebaseDatabaseRefProperty.value = ref
  }

  private let forceUseHLSProperty = MutableProperty()
  internal func forceUseHLS() {
    self.forceUseHLSProperty.value = ()
  }

  private let greenRoomOffProperty = MutableProperty<AnyObject?>(nil)
  internal func observedGreenRoomOffChanged(off off: AnyObject?) {
    self.greenRoomOffProperty.value = off
  }

  private let hlsUrlProperty = MutableProperty<AnyObject?>(nil)
  internal func observedHlsUrlChanged(hlsUrl hlsUrl: AnyObject?) {
    self.hlsUrlProperty.value = hlsUrl
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<AnyObject?>(nil)
  internal func observedNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: AnyObject?) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let scaleNumberOfPeopleWatchingProperty = MutableProperty<AnyObject?>(nil)
  internal func observedScaleNumberOfPeopleWatchingChanged(numberOfPeople numberOfPeople: AnyObject?) {
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
