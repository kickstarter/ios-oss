import FirebaseDatabase
import ReactiveSwift

public enum LiveApiError: Error {
  case failedToInitializeFirebase
  case firebaseAnonymousAuthFailed
  case firebaseCustomTokenAuthFailed
  case genericFailure
  case invalidEventId
  case invalidJson
  case invalidProjectId
}

public protocol LiveStreamServiceProtocol {
  init()

  /// Fetches the initial limited value of the chat messages.
  func chatMessageSnapshotsValue(withDatabaseRef dbRef: FirebaseDatabaseReferenceType,
                                 refConfig: FirebaseRefConfig, limitedToLast limit: UInt) ->
    SignalProducer<FirebaseDataSnapshotType, LiveApiError>

  /// Emits chat messages added since a given time interval.
  func chatMessageSnapshotsAdded(withDatabaseRef dbRef: FirebaseDatabaseReferenceType,
                                 refConfig: FirebaseRefConfig,
                                 addedSinceTimeInterval timeInterval: TimeInterval) ->
    SignalProducer<FirebaseDataSnapshotType, LiveApiError>

  /// Fetches an event with personalization added for the user.
  func fetchEvent(eventId: Int, uid: Int?, liveAuthToken: String?) ->
    SignalProducer<LiveStreamEvent, LiveApiError>

  /// Fetches an array of live streaming events.
  func fetchEvents() -> SignalProducer<[LiveStreamEvent], LiveApiError>

  /// Fetches an array of events with personalization added for the user.
  func fetchEvents(forProjectId projectId: Int, uid: Int?) -> SignalProducer<LiveStreamEventsEnvelope,
    LiveApiError>

  /// Returns the current Firebase app instance and instantiates it if it doesn't exist.
  func firebaseApp() -> SignalProducer<FirebaseAppType, LiveApiError>

  /// Returns the auth instance for the current app
  func firebaseAuth(withApp app: FirebaseAppType) -> SignalProducer<FirebaseAuthType, LiveApiError>

  /// Returns the database reference for the given app.
  func firebaseDatabaseRef(withApp app: FirebaseAppType) ->
    SignalProducer<FirebaseDatabaseReferenceType, LiveApiError>

  /// Emits the green room status for a live stream.
  func greenRoomStatus(withDatabaseRef dbRef: FirebaseDatabaseReferenceType,
                       refConfig: FirebaseRefConfig) -> SignalProducer<Bool?, LiveApiError>

  /// Acquires an anonymous id to be used in the case that a user is not logged-in.
  func signInToFirebaseAnonymously(withAuth auth: FirebaseAuthType) -> SignalProducer<String, LiveApiError>

  /// Acquires a firebase user id to be used in the case that a user is logged-in.
  func signIn(withAuth auth: FirebaseAuthType, customToken: String) ->
    SignalProducer<String, LiveApiError>

  /// Subscribes/unsubscribes a user to an event.
  func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool) ->
    SignalProducer<LiveStreamSubscribeEnvelope, LiveApiError>
}
