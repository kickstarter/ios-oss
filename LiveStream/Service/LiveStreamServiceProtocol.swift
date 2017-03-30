import FirebaseDatabase
import ReactiveSwift

public enum LiveApiError: Error {
  case chatMessageDecodingFailed
  case failedToInitializeFirebase
  case firebaseAnonymousAuthFailed
  case firebaseCustomTokenAuthFailed
  case sendChatMessageFailed
  case snapshotDecodingFailed(path: String)
  case genericFailure
  case invalidJson
  case invalidRequest
}

extension LiveApiError: Equatable {
  public static func == (lhs: LiveApiError, rhs: LiveApiError) -> Bool {
    switch (lhs, rhs) {
    case (.chatMessageDecodingFailed, .chatMessageDecodingFailed):
      return true
    case (failedToInitializeFirebase, .failedToInitializeFirebase):
      return true
    case (firebaseAnonymousAuthFailed, .firebaseAnonymousAuthFailed):
      return true
    case (firebaseCustomTokenAuthFailed, .firebaseCustomTokenAuthFailed):
      return true
    case (sendChatMessageFailed, .sendChatMessageFailed):
      return true
    case (snapshotDecodingFailed(let lhsPath), .snapshotDecodingFailed(let rhsPath)):
      return lhsPath == rhsPath
    case (genericFailure, .genericFailure):
      return true
    case (invalidJson, .invalidJson):
      return true
    case (invalidRequest, .invalidRequest):
      return true
    case (chatMessageDecodingFailed, _), (failedToInitializeFirebase, _), (firebaseAnonymousAuthFailed, _),
         (firebaseCustomTokenAuthFailed, _), (sendChatMessageFailed, _), (snapshotDecodingFailed, _),
         (genericFailure, _), (invalidJson, _), (invalidRequest, _):
      return false
    }
  }
}

public protocol LiveStreamServiceProtocol {
  init()

  /// Called to initialise internal Firebase properties.
  func setup()

  /// Emits chat messages added since a given time interval.
  func chatMessagesAdded(withPath path: String, addedSinceTimeInterval timeInterval: TimeInterval) ->
    SignalProducer<LiveStreamChatMessage, LiveApiError>

  /// Fetches an event with personalization added for the user.
  func fetchEvent(eventId: Int, uid: Int?, liveAuthToken: String?) ->
    SignalProducer<LiveStreamEvent, LiveApiError>

  /// Fetches an array of live streaming events.
  func fetchEvents() -> SignalProducer<[LiveStreamEvent], LiveApiError>

  /// Fetches an array of events with personalization added for the user.
  func fetchEvents(forProjectId projectId: Int, uid: Int?) -> SignalProducer<LiveStreamEventsEnvelope,
    LiveApiError>

  /// Emits the green room off status for a live stream.
  func greenRoomOffStatus(withPath path: String) -> SignalProducer<Bool, LiveApiError>

  /// Emits the HLS url for the live stream if it changes after going live.
  func hlsUrl(withPath path: String) -> SignalProducer<String, LiveApiError>

  /// Fetches the initial limited value of the chat messages.
  func initialChatMessages(withPath path: String, limitedToLast limit: UInt) ->
    SignalProducer<[LiveStreamChatMessage], LiveApiError>

  /// Emits the number of people watching for a normal live stream event.
  func numberOfPeopleWatching(withPath path: String) ->
    SignalProducer<Int, LiveApiError>

  /// Writes a value to increment the number of people watching.
  func incrementNumberOfPeopleWatching(withPath path: String) ->
    SignalProducer<(), LiveApiError>

  /// Emits the number of people watching for a scale live stream event.
  func scaleNumberOfPeopleWatching(withPath path: String) ->
    SignalProducer<Int, LiveApiError>

  /// Sends a new chat message to the live chat.
  func sendChatMessage(withPath path: String,
                       chatMessage message: NewLiveStreamChatMessage) -> SignalProducer<(), LiveApiError>

  /// Acquires an anonymous Firebase user id to be used in the case that a user is not logged-in.
  func signInToFirebaseAnonymously() -> SignalProducer<String, LiveApiError>

  /// Acquires a Firebase user id to be used in the case that a user is logged-in.
  func signInToFirebase(withCustomToken customToken: String) -> SignalProducer<String, LiveApiError>

  /// Subscribes/unsubscribes a user to an event.
  func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool) ->
    SignalProducer<LiveStreamSubscribeEnvelope, LiveApiError>
}
