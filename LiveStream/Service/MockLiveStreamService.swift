import FirebaseDatabase
import Prelude
import ReactiveSwift
import Result

extension Result {
  private var value: T? {
    switch self {
    case let .success(value): return value
    case .failure:            return nil
    }
  }
}

internal struct MockLiveStreamService: LiveStreamServiceProtocol {
  private let anonymousUserId: String?
  private let fetchEventResult: Result<LiveStreamEvent, LiveApiError>?
  private let fetchEventsForProjectResult: Result<LiveStreamEventsEnvelope, LiveApiError>?
  private let fetchEventsResult: Result<[LiveStreamEvent], LiveApiError>?
  private let firebaseUserId: String?
  private let initializeDatabaseResult: Result<FIRDatabaseReference, SomeError>?
  private let subscribeToResult: Result<LiveStreamSubscribeEnvelope, LiveApiError>?

  internal init() {
    self.init(fetchEventResult: nil)
  }

  internal init(anonymousUserId: String? = nil,
                fetchEventResult: Result<LiveStreamEvent, LiveApiError>? = nil,
                fetchEventsForProjectResult: Result<LiveStreamEventsEnvelope, LiveApiError>? = nil,
                fetchEventsResult: Result<[LiveStreamEvent], LiveApiError>? = nil,
                firebaseUserId: String? = nil,
                initializeDatabaseResult: Result<FIRDatabaseReference, SomeError>? = nil,
                subscribeToResult: Result<LiveStreamSubscribeEnvelope, LiveApiError>? = nil) {
    self.anonymousUserId = anonymousUserId
    self.fetchEventResult = fetchEventResult
    self.fetchEventsForProjectResult = fetchEventsForProjectResult
    self.fetchEventsResult = fetchEventsResult
    self.firebaseUserId = firebaseUserId
    self.initializeDatabaseResult = initializeDatabaseResult
    self.subscribeToResult = subscribeToResult
  }

  internal func setup() {

  }

  internal func fetchEvent(eventId: Int, uid: Int?, liveAuthToken: String?) ->
    SignalProducer<LiveStreamEvent, LiveApiError> {
      if let error = self.fetchEventResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(value:
        self.fetchEventResult?.value
          ?? .template |> LiveStreamEvent.lens.id .~ eventId
      )
  }

  internal func fetchEvents(forProjectId projectId: Int, uid: Int?) ->
    SignalProducer<LiveStreamEventsEnvelope, LiveApiError> {
    if let error = self.fetchEventsForProjectResult?.error {
      return SignalProducer(error: error)
    }

    let envelope = LiveStreamEventsEnvelope(numberOfLiveStreams: 1,
                                            liveStreamEvents: [LiveStreamEvent.template])

    return SignalProducer(value:
      self.fetchEventsForProjectResult?.value
        ?? envelope
    )
  }

  internal func fetchEvents() -> SignalProducer<[LiveStreamEvent], LiveApiError> {

    if let error = self.fetchEventsResult?.error {
      return SignalProducer(error: error)
    }

    return SignalProducer(
      value: self.fetchEventsResult?.value ?? [.template]
    )
  }

  internal func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool) ->
    SignalProducer<LiveStreamSubscribeEnvelope, LiveApiError> {

      if let error = self.subscribeToResult?.error {
        return SignalProducer(error: error)
      }

      let envelope = LiveStreamSubscribeEnvelope(success: true, reason: nil)

      return SignalProducer(value: self.subscribeToResult?.value ?? envelope)
  }


  //fixme: just for conformance

  func chatMessageSnapshotsAdded(withPath path: String, addedSinceTimeInterval timeInterval: TimeInterval) -> SignalProducer<LiveStreamChatMessage, LiveApiError> {
    return .empty
  }

  func chatMessageSnapshotsValue(withPath path: String, limitedToLast limit: UInt) -> SignalProducer<[LiveStreamChatMessage], LiveApiError> {
    return .empty
  }

  func greenRoomOffStatus(withPath path: String) -> SignalProducer<Bool, LiveApiError> {
    return .empty
  }

  func hlsUrl(withPath path: String) -> SignalProducer<String, LiveApiError> {
    return .empty
  }

  func numberOfPeopleWatching(withPath path: String) -> SignalProducer<Int, LiveApiError> {
    return .empty
  }

  func incrementNumberOfPeopleWatching(withPath path: String) ->
    SignalProducer<(), LiveApiError> {
    return .empty
  }

  func scaleNumberOfPeopleWatching(withPath path: String) -> SignalProducer<Int, LiveApiError> {
    return .empty
  }

  func sendChatMessage(withPath path: String, chatMessage message: NewLiveStreamChatMessage) -> SignalProducer<(), LiveApiError> {
    return .empty
  }

  func signInToFirebaseAnonymously() -> SignalProducer<String, LiveApiError> {
    return .empty
  }

  func signInToFirebase(withCustomToken customToken: String) -> SignalProducer<String, LiveApiError> {
    return .empty
  }
}
