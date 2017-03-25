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
  private let chatMessagesSnapshotsAddedResult: Result<[LiveStreamChatMessage], LiveApiError>?
  private let chatMessagesSnapshotsValueResult: Result<[[LiveStreamChatMessage]], LiveApiError>?
  private let greenRoomOffStatusResult: Result<[Bool], LiveApiError>?
  private let fetchEventResult: Result<LiveStreamEvent, LiveApiError>?
  private let fetchEventsForProjectResult: Result<LiveStreamEventsEnvelope, LiveApiError>?
  private let fetchEventsResult: Result<[LiveStreamEvent], LiveApiError>?
  private let hlsUrlResult: Result<[String], LiveApiError>?
  private let incrementNumberOfPeopleWatchingResult: Result<[()], LiveApiError>?
  private let numberOfPeopleWatchingResult: Result<[Int], LiveApiError>?
  private let scaleNumberOfPeopleWatchingResult: Result<[Int], LiveApiError>?
  private let sendChatMessageResult: Result<[()], LiveApiError>?
  private let signInToFirebaseAnonymouslyResult: Result<[String], LiveApiError>?
  private let signInToFirebaseWithCustomTokenResult: Result<[String], LiveApiError>?
  private let subscribeToResult: Result<LiveStreamSubscribeEnvelope, LiveApiError>?

  internal init() {
    self.init(fetchEventResult: nil)
  }

  internal init(chatMessagesSnapshotsAddedResult: Result<[LiveStreamChatMessage], LiveApiError>? = nil,
                chatMessagesSnapshotsValueResult: Result<[[LiveStreamChatMessage]], LiveApiError>? = nil,
                greenRoomOffStatusResult: Result<[Bool], LiveApiError>? = nil,
                fetchEventResult: Result<LiveStreamEvent, LiveApiError>? = nil,
                fetchEventsForProjectResult: Result<LiveStreamEventsEnvelope, LiveApiError>? = nil,
                fetchEventsResult: Result<[LiveStreamEvent], LiveApiError>? = nil,
                hlsUrlResult: Result<[String], LiveApiError>? = nil,
                incrementNumberOfPeopleWatchingResult: Result<[()], LiveApiError>? = nil,
                numberOfPeopleWatchingResult: Result<[Int], LiveApiError>? = nil,
                scaleNumberOfPeopleWatchingResult: Result<[Int], LiveApiError>? = nil,
                sendChatMessageResult: Result<[()], LiveApiError>? = nil,
                signInToFirebaseAnonymouslyResult: Result<[String], LiveApiError>? = nil,
                signInToFirebaseWithCustomTokenResult: Result<[String], LiveApiError>? = nil,
                subscribeToResult: Result<LiveStreamSubscribeEnvelope, LiveApiError>? = nil) {
    self.chatMessagesSnapshotsAddedResult = chatMessagesSnapshotsAddedResult
    self.chatMessagesSnapshotsValueResult = chatMessagesSnapshotsValueResult
    self.greenRoomOffStatusResult = greenRoomOffStatusResult
    self.fetchEventResult = fetchEventResult
    self.fetchEventsForProjectResult = fetchEventsForProjectResult
    self.fetchEventsResult = fetchEventsResult
    self.hlsUrlResult = hlsUrlResult
    self.incrementNumberOfPeopleWatchingResult = incrementNumberOfPeopleWatchingResult
    self.numberOfPeopleWatchingResult = numberOfPeopleWatchingResult
    self.scaleNumberOfPeopleWatchingResult = scaleNumberOfPeopleWatchingResult
    self.sendChatMessageResult = sendChatMessageResult
    self.signInToFirebaseAnonymouslyResult = signInToFirebaseAnonymouslyResult
    self.signInToFirebaseWithCustomTokenResult = signInToFirebaseWithCustomTokenResult
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

  // MARK: Firebase

  internal func chatMessageSnapshotsAdded(withPath path: String,
                                          addedSinceTimeInterval timeInterval: TimeInterval) ->
    SignalProducer<LiveStreamChatMessage, LiveApiError> {
      if let error = self.chatMessagesSnapshotsAddedResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        self.chatMessagesSnapshotsAddedResult?.value ?? []
      )
  }

  internal func chatMessageSnapshotsValue(withPath path: String, limitedToLast limit: UInt) ->
    SignalProducer<[LiveStreamChatMessage], LiveApiError> {
      if let error = self.chatMessagesSnapshotsValueResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        self.chatMessagesSnapshotsValueResult?.value ?? []
      )
  }

  internal func greenRoomOffStatus(withPath path: String) -> SignalProducer<Bool, LiveApiError> {
    if let error = self.greenRoomOffStatusResult?.error {
      return SignalProducer(error: error)
    }

    return SignalProducer(
      self.greenRoomOffStatusResult?.value ?? []
    )
  }

  internal func hlsUrl(withPath path: String) -> SignalProducer<String, LiveApiError> {
    if let error = self.hlsUrlResult?.error {
      return SignalProducer(error: error)
    }

    return SignalProducer(
      self.hlsUrlResult?.value ?? []
    )
  }

  internal func numberOfPeopleWatching(withPath path: String) -> SignalProducer<Int, LiveApiError> {
    if let error = self.numberOfPeopleWatchingResult?.error {
      return SignalProducer(error: error)
    }

    return SignalProducer(
      self.numberOfPeopleWatchingResult?.value ?? []
    )
  }

  internal func incrementNumberOfPeopleWatching(withPath path: String) ->
    SignalProducer<(), LiveApiError> {
      if let error = self.incrementNumberOfPeopleWatchingResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        self.incrementNumberOfPeopleWatchingResult?.value ?? []
      )
  }

  internal func scaleNumberOfPeopleWatching(withPath path: String) -> SignalProducer<Int, LiveApiError> {
    if let error = self.scaleNumberOfPeopleWatchingResult?.error {
      return SignalProducer(error: error)
    }

    return SignalProducer(
      self.scaleNumberOfPeopleWatchingResult?.value ?? []
    )
  }

  internal func sendChatMessage(withPath path: String, chatMessage message: NewLiveStreamChatMessage) ->
    SignalProducer<(), LiveApiError> {
      if let error = self.sendChatMessageResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        self.sendChatMessageResult?.value ?? []
      )
  }

  internal func signInToFirebaseAnonymously() -> SignalProducer<String, LiveApiError> {
    if let error = self.signInToFirebaseAnonymouslyResult?.error {
      return SignalProducer(error: error)
    }

    return SignalProducer(
      self.signInToFirebaseAnonymouslyResult?.value ?? []
    )
  }

  internal func signInToFirebase(withCustomToken customToken: String) ->
    SignalProducer<String, LiveApiError> {
      if let error = self.signInToFirebaseWithCustomTokenResult?.error {
        return SignalProducer(error: error)
      }
      
      return SignalProducer(
        self.signInToFirebaseWithCustomTokenResult?.value ?? []
      )
  }
}
