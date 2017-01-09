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
  func configureWith(databaseRef databaseRef: FirebaseDatabaseReferenceType, event: LiveStreamEvent)

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

    let databaseRef = configData.map(first)
    let liveStreamEvent = configData.map(second)

    let observedNumberOfPeopleWatchingChanged = self.numberOfPeopleWatchingProperty.signal
      .map { $0 as? NSDictionary }
      .ignoreNil()
      .map { $0.allKeys.count }

    let observedScaleNumberOfPeopleWatchingChanged = self.scaleNumberOfPeopleWatchingProperty.signal
      .map { $0 as? Int }
      .ignoreNil()

    let numberOfPeopleWatching = Signal.merge(
      observedNumberOfPeopleWatchingChanged,
      observedScaleNumberOfPeopleWatchingChanged
    )

    let maxOpenTokViewers = liveStreamEvent.map { $0.stream.maxOpenTokViewers }

    // FIXME: need to write a test for this?
    let everySecondTimer = self.viewDidLoadProperty.signal.flatMap { timer(1, onScheduler: scheduler) }

    let liveStreamWasNonStarter = liveStreamEvent
      .takeWhen(everySecondTimer)
      .filter { event in
        !event.stream.liveNow
          && !event.stream.hasReplay
          && startDateMoreThanFifteenMinutesAgo(event: event)
      }
      .ignoreValues()

    let didLiveStreamEndedNormally = liveStreamEvent
      .map { event in !event.stream.liveNow && event.stream.hasReplay }

    let observedHlsUrlChanged = self.hlsUrlProperty.signal
      .map { $0 as? String }
      .ignoreNil()

    let observedGreenRoomOffChanged = self.greenRoomOffProperty
      .signal
      .map { $0 as? Bool }
      .ignoreNil()

    let isMaxOpenTokViewersReached = combineLatest(
      numberOfPeopleWatching,
      maxOpenTokViewers
      )
      .map { $0 > $1 }
      .take(1)

    // FIXME: lots of tests for non-live replay

    let forceHls = Signal.merge(
      // FIXME: write test for hls starting immediately in case of non-live
//      didLiveStreamEndedNormally.filter(isTrue).mapConst(true),
      self.viewDidLoadProperty.signal.delay(10, onScheduler: scheduler).mapConst(true),
      isMaxOpenTokViewersReached,
      liveStreamEvent.filter { $0.stream.isRtmp }.mapConst(true)
      )
      .take(1)

    let useHlsStream = zip(
      forceHls,
      didLiveStreamEndedNormally
      )
      .map { $0 || $1 }
      .take(1)

    let liveHlsUrl = Signal.merge(
      liveStreamEvent.map { LiveStreamType.hlsStream(hlsStreamUrl: $0.stream.hlsUrl) },
      observedHlsUrlChanged.map(LiveStreamType.hlsStream)
      )

    let replayHlsUrl = liveStreamEvent
      .takeWhen(didLiveStreamEndedNormally)
      .map { $0.stream.replayUrl }
      .ignoreNil()
      .map(LiveStreamType.hlsStream)

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

    self.createVideoViewController = combineLatest(
      liveStreamType,
      observedGreenRoomOffChanged.filter(isTrue)
      )
      .map(first)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = numberOfPeopleWatching

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

    self.removeVideoViewController = self.createVideoViewController.take(1)
      .sampleOn(observedGreenRoomOffChanged.filter(isFalse).ignoreValues())
      .ignoreValues()

    let greenRoomState = observedGreenRoomOffChanged
      .map(isFalse)
      .mapConst(LiveStreamViewControllerState.greenRoom)

    let replayState = didLiveStreamEndedNormally
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.ignoreNil())
      .map { _, playbackState in
        LiveStreamViewControllerState.replay(playbackState: playbackState, duration: 0)
    }

    let liveState = liveStreamEvent
      .takePairWhen(self.videoPlaybackStateChangedProperty.signal.ignoreNil())
      .filter { event, _ in event.stream.liveNow }
      .map { _, playbackState in
        LiveStreamViewControllerState.live(playbackState: playbackState, startTime: 0)
    }

    let errorState = self.videoPlaybackStateChangedProperty.signal.ignoreNil()
      .map { $0.error }
      .ignoreNil()
      .map(LiveStreamViewControllerState.error)

    let nonStarterState = liveStreamWasNonStarter
      .mapConst(LiveStreamViewControllerState.nonStarter)

    // FIXME: write tests
    self.notifyDelegateLiveStreamViewControllerStateChanged = Signal.merge(
      errorState,
      greenRoomState,
      liveState,
      nonStarterState,
      replayState
    )
  }

  private let configData = MutableProperty<(FirebaseDatabaseReferenceType, LiveStreamEvent)?>(nil)
  internal func configureWith(databaseRef databaseRef: FirebaseDatabaseReferenceType, event: LiveStreamEvent) {
    self.configData.value = (databaseRef, event)
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
  internal let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged: Signal<Int, NoError>
  internal let notifyDelegateLiveStreamViewControllerStateChanged: Signal<LiveStreamViewControllerState,
    NoError>
  internal let removeVideoViewController: Signal<(), NoError>

  internal var inputs: LiveStreamViewModelInputs { return self }
  internal var outputs: LiveStreamViewModelOutputs { return self }
}

private func startDateMoreThanFifteenMinutesAgo(event event: LiveStreamEvent) -> Bool {
  return NSCalendar.currentCalendar()
    .components(.Minute, fromDate: event.stream.startDate, toDate: NSDate(), options: [])
    .minute > 15
}
