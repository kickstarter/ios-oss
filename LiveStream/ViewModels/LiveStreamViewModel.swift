import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

internal protocol LiveStreamViewModelType {
  var inputs: LiveStreamViewModelInputs { get }
  var outputs: LiveStreamViewModelOutputs { get }
}

internal protocol LiveStreamViewModelInputs {
  /// Call to set the Firebase app and LiveStreamEvent
  func configureWith(event: LiveStreamEvent, userId: Int?)

  /// Call when the firebase database is created.
  func createdDatabaseRef(ref: FirebaseDatabaseReferenceType)

  /// Called when the Firebase app fails to initialise
  func firebaseAppFailedToInitialize()

  /// Called when the green room changes to active or inactive when a creator goes on/off live, expects a Bool
  func observedGreenRoomOffChanged(off: Any?)

  /// Called when the HLS url for the stream changes, expects a String
  func observedHlsUrlChanged(hlsUrl: Any?)

  /// Called when the number of people watching changes in a non-scale event, expects an NSDictionary
  func observedNumberOfPeopleWatchingChanged(numberOfPeople: Any?)

  /// Called when the number of people watching changes in a scaled event, expects an Int
  func observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: Any?)

  /// Called to set the Firebase user ID
  func setFirebaseUserId(userId: String)

  /// Called when the video playback state changes
  func videoPlaybackStateChanged(state: LiveVideoPlaybackState)

  /// Call when the viewDidLoad
  func viewDidLoad()
}

internal protocol LiveStreamViewModelOutputs {
  /// Create the presence reference to update Firebase on connect/disconnect
  var createPresenceReference: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError> { get }

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

  /// Emits an event and user id when the firebase database should be initialized.
  var initializeFirebase: Signal<(LiveStreamEvent, Int?), NoError> { get }

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
  init(scheduler: DateSchedulerProtocol = QueueScheduler.main) {

    let configData = Signal.combineLatest(self.configData.signal.skipNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let liveStreamEvent = configData.map(first)
    let userId = configData.map(second)

    let observedNumberOfPeopleWatchingChanged = self.numberOfPeopleWatchingProperty.signal
      .map { $0 as? NSDictionary }
      .skipNil()
      .map { $0.allKeys.count }

    let observedScaleNumberOfPeopleWatchingChanged = self.scaleNumberOfPeopleWatchingProperty.signal
      .map { $0 as? Int }
      .skipNil()

    let numberOfPeopleWatching = Signal.merge(
      observedNumberOfPeopleWatchingChanged,
      observedScaleNumberOfPeopleWatchingChanged
    )

    let maxOpenTokViewers = liveStreamEvent.map { $0.stream.maxOpenTokViewers }

    let didLiveStreamEndedNormally = liveStreamEvent
      .map(didEndNormally(event:))

    let observedHlsUrlChanged = self.hlsUrlProperty.signal
      .map { $0 as? String }
      .skipNil()

    let observedGreenRoomOffChanged = self.greenRoomOffProperty
      .signal
      .map { $0 as? Bool }
      .skipNil()

    let isMaxOpenTokViewersReached = Signal.combineLatest(
      numberOfPeopleWatching,
      maxOpenTokViewers
      )
      .map { $0 > $1 }
      .take(first: 1)

    let useHlsStream = Signal.merge(
      isMaxOpenTokViewersReached,

      liveStreamEvent
        .map { event in event.stream.isRtmp || didEndNormally(event: event) }
        .filter(isTrue)
      )
      .take(first: 1)
      .timeout(after: 10, raising: SomeError(), on: scheduler)
      .flatMapError { _ in SignalProducer<Bool, NoError>(value: true) }

    let liveHlsUrl = Signal.merge(
      liveStreamEvent
        .filter { $0.stream.liveNow }
        .map { $0.stream.hlsUrl }
        .skipNil()
        .map(LiveStreamType.hlsStream),
      observedHlsUrlChanged.map(LiveStreamType.hlsStream)
    )

    let replayHlsUrl = liveStreamEvent
      .filter(didEndNormally(event:))
      .map { $0.stream.replayUrl }
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
      observedGreenRoomOffChanged.filter(isTrue),
      didLiveStreamEndedNormally.filter(isTrue)
      )
      .ignoreValues()

    self.createVideoViewController = Signal.combineLatest(
      liveStreamType,
      observedGreenRoomOffOrInReplay
      )
      .map(first)

    self.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged = numberOfPeopleWatching

    let createObservers = Signal.zip(
      didLiveStreamEndedNormally.filter(isFalse),
      liveStreamEvent.map(isNonStarter(event:)).filter(isFalse)
      )
      .ignoreValues()

    let combinedUserId = Signal.merge(
      userId.skipNil().map(String.init),
      self.firebaseUserIdProperty.signal.skipNil()
      ).take(first: 1)

    let databaseRef = self.databaseRefProperty.signal.skipNil()

    self.createPresenceReference = Signal.zip(
      databaseRef,
      Signal.combineLatest(
        liveStreamEvent.map { $0.firebase.numberPeopleWatchingPath },
        combinedUserId
        )
        .map { "\($0)/\($1)" }
        .map { FirebaseRefConfig(ref: $0, orderBy: "") },
      createObservers
      ).map { dbRef, event, _ in (dbRef, event) }

    self.createGreenRoomObservers = Signal.zip(
      databaseRef,
      liveStreamEvent
        .map { FirebaseRefConfig(ref: $0.firebase.greenRoomPath, orderBy: "") },
      createObservers
      ).map { dbRef, event, _ in (dbRef, event) }

    self.createHLSObservers = Signal.zip(
      databaseRef,
      liveStreamEvent
        .map { FirebaseRefConfig(ref: $0.firebase.hlsUrlPath, orderBy: "") },
      createObservers
      ).map { dbRef, event, _ in (dbRef, event) }

    self.createNumberOfPeopleWatchingObservers = Signal.zip(
      databaseRef,
      liveStreamEvent
        .filter { !$0.stream.isScale }
        .map { FirebaseRefConfig(ref: $0.firebase.numberPeopleWatchingPath, orderBy: "") },
      createObservers
      ).map { dbRef, event, _ in (dbRef, event) }

    self.createScaleNumberOfPeopleWatchingObservers = Signal.zip(
      databaseRef,
      liveStreamEvent
        .filter { $0.stream.isScale }
        .map { FirebaseRefConfig(ref: $0.firebase.scaleNumberPeopleWatchingPath, orderBy: "") },
      createObservers
      ).map { dbRef, event, _ in (dbRef, event) }

    self.removeVideoViewController = self.createVideoViewController.take(first: 1)
      .sample(on: observedGreenRoomOffChanged.filter(isFalse).ignoreValues())
      .ignoreValues()

    let greenRoomState = observedGreenRoomOffChanged
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
        event.stream.liveNow && !playbackState.isError
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

    self.notifyDelegateLiveStreamViewControllerStateChanged = Signal.merge(
      nonStarterOrLoadingState,
      errorState,
      self.firebaseAppFailedToInitializeProperty.signal.mapConst(.initializationFailed),
      greenRoomState,
      liveState,
      replayState
    )

    self.initializeFirebase = configData
      .filter { event, _ in event.stream.liveNow }
  }

  private let configData = MutableProperty<(LiveStreamEvent, Int?)?>(nil)
  internal func configureWith(event: LiveStreamEvent, userId: Int?) {
    self.configData.value = (event, userId)
  }

  private let databaseRefProperty = MutableProperty<FirebaseDatabaseReferenceType?>(nil)
  internal func createdDatabaseRef(ref: FirebaseDatabaseReferenceType) {
    self.databaseRefProperty.value = ref
  }

  private let firebaseAppFailedToInitializeProperty = MutableProperty()
  internal func firebaseAppFailedToInitialize() {
    self.firebaseAppFailedToInitializeProperty.value = ()
  }

  private let greenRoomOffProperty = MutableProperty<Any?>(nil)
  internal func observedGreenRoomOffChanged(off: Any?) {
    self.greenRoomOffProperty.value = off
  }

  private let hlsUrlProperty = MutableProperty<Any?>(nil)
  internal func observedHlsUrlChanged(hlsUrl: Any?) {
    self.hlsUrlProperty.value = hlsUrl
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Any?>(nil)
  internal func observedNumberOfPeopleWatchingChanged(numberOfPeople: Any?) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let scaleNumberOfPeopleWatchingProperty = MutableProperty<Any?>(nil)
  internal func observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: Any?) {
    self.scaleNumberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let firebaseUserIdProperty = MutableProperty<String?>(nil)
  internal func setFirebaseUserId(userId: String) {
    self.firebaseUserIdProperty.value = userId
  }

  private let videoPlaybackStateChangedProperty = MutableProperty<LiveVideoPlaybackState?>(nil)
  internal func videoPlaybackStateChanged(state: LiveVideoPlaybackState) {
    self.videoPlaybackStateChangedProperty.value = state
  }

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let createPresenceReference: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>
  internal let createGreenRoomObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>
  internal let createHLSObservers: Signal<(FirebaseDatabaseReferenceType, FirebaseRefConfig), NoError>
  internal let createNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>
  internal let createScaleNumberOfPeopleWatchingObservers: Signal<(FirebaseDatabaseReferenceType,
    FirebaseRefConfig), NoError>
  internal let createVideoViewController: Signal<LiveStreamType, NoError>
  internal let initializeFirebase: Signal<(LiveStreamEvent, Int?), NoError>
  internal let notifyDelegateLiveStreamNumberOfPeopleWatchingChanged: Signal<Int, NoError>
  internal let notifyDelegateLiveStreamViewControllerStateChanged: Signal<LiveStreamViewControllerState,
    NoError>
  internal let removeVideoViewController: Signal<(), NoError>

  internal var inputs: LiveStreamViewModelInputs { return self }
  internal var outputs: LiveStreamViewModelOutputs { return self }
}

private func isNonStarter(event: LiveStreamEvent) -> Bool {
  return !event.stream.liveNow
    && !event.stream.definitelyHasReplay
    && startDateMoreThanFifteenMinutesAgo(event: event)
}

private func startDateMoreThanFifteenMinutesAgo(event: LiveStreamEvent) -> Bool {
  let minute = Calendar.current
    .dateComponents([.minute], from: event.stream.startDate as Date, to: Date())
    .minute ?? 0
  return minute > 15
}

private func didEndNormally(event: LiveStreamEvent) -> Bool {
  return !event.stream.liveNow && event.stream.definitelyHasReplay
}
