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

  internal func deleteDatabase() {
  }

  internal func signInAnonymously(completion: @escaping (String) -> Void) {
    anonymousUserId.doIfSome(completion)
  }

  internal func signIn(withCustomToken customToken: String, completion: @escaping (String) -> Void) {
    firebaseUserId.doIfSome(completion)
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

  internal func initializeDatabase(failed: (Void) -> Void,
                                   succeeded: (FIRDatabaseReference) -> Void) {

    switch initializeDatabaseResult {
    case let .some(.success(ref)):
      succeeded(ref)
    case .some(.failure), .none:
      failed()
    }
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

  func chatMessageSnapshotsValue(withDatabaseRef dbRef: FirebaseDatabaseReferenceType, refConfig: FirebaseRefConfig, limitedToLast limit: UInt) -> SignalProducer<FirebaseDataSnapshotType, LiveApiError> {
    return .empty
  }

  func chatMessageSnapshotsAdded(withDatabaseRef dbRef: FirebaseDatabaseReferenceType, refConfig: FirebaseRefConfig, addedSinceTimeInterval timeInterval: TimeInterval) -> SignalProducer<FirebaseDataSnapshotType, LiveApiError> {
    return .empty
  }

  func firebaseApp() -> SignalProducer<FirebaseAppType, LiveApiError> {
    return .empty
  }

  func firebaseAuth(withApp app: FirebaseAppType) -> SignalProducer<FirebaseAuthType, LiveApiError> {
    return .empty
  }

  func firebaseDatabaseRef(withApp app: FirebaseAppType) -> SignalProducer<FirebaseDatabaseReferenceType, LiveApiError> {
    return .empty
  }

  func greenRoomStatus(withDatabaseRef dbRef: FirebaseDatabaseReferenceType, refConfig: FirebaseRefConfig) -> SignalProducer<Bool?, LiveApiError> {
    return .empty
  }

  func signIn(withAuth auth: FirebaseAuthType, customToken: String) -> SignalProducer<String, LiveApiError> {
    return .empty
  }

  func signInToFirebaseAnonymously(withAuth auth: FirebaseAuthType) -> SignalProducer<String, LiveApiError> {
    return .empty
  }
}
