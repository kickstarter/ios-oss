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
  func chatMessageSnapshotsValue(withRefConfig refConfig: FirebaseRefConfig, limitedToLast limit: UInt) ->
    SignalProducer<[LiveStreamChatMessage], LiveApiError>

  /// Emits chat messages added since a given time interval.
  func chatMessageSnapshotsAdded(withRefConfig refConfig: FirebaseRefConfig,
                                 addedSinceTimeInterval timeInterval: TimeInterval) ->
    SignalProducer<LiveStreamChatMessage, LiveApiError>

  /// Fetches an event with personalization added for the user.
  func fetchEvent(eventId: Int, uid: Int?, liveAuthToken: String?) ->
    SignalProducer<LiveStreamEvent, LiveApiError>

  /// Fetches an array of live streaming events.
  func fetchEvents() -> SignalProducer<[LiveStreamEvent], LiveApiError>

  /// Fetches an array of events with personalization added for the user.
  func fetchEvents(forProjectId projectId: Int, uid: Int?) -> SignalProducer<LiveStreamEventsEnvelope,
    LiveApiError>

  /// Emits the green room status for a live stream.
  func greenRoomStatus(withRefConfig refConfig: FirebaseRefConfig) -> SignalProducer<Bool?, LiveApiError>

  /// Acquires an anonymous id to be used in the case that a user is not logged-in.
  func signInToFirebaseAnonymously() -> SignalProducer<String, LiveApiError>

  /// Acquires a firebase user id to be used in the case that a user is logged-in.
  func signIn(withCustomToken customToken: String) -> SignalProducer<String, LiveApiError>

  /// Subscribes/unsubscribes a user to an event.
  func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool) ->
    SignalProducer<LiveStreamSubscribeEnvelope, LiveApiError>
}
