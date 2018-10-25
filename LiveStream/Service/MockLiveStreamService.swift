import FirebaseDatabase
import Prelude
import ReactiveSwift
import Result

internal struct MockLiveStreamService: LiveStreamServiceProtocol {
  private let chatMessagesAddedResult: Result<[LiveStreamChatMessage], LiveApiError>?
  private let greenRoomOffStatusResult: Result<[Bool], LiveApiError>?
  private let fetchEventResult: Result<LiveStreamEvent, LiveApiError>?
  private let fetchEventsForProjectResult: Result<LiveStreamEventsEnvelope, LiveApiError>?
  private let fetchEventsResult: Result<[LiveStreamEvent], LiveApiError>?
  private let hlsUrlResult: Result<[String], LiveApiError>?
  private let incrementNumberOfPeopleWatchingResult: Result<[()], LiveApiError>?
  private let initialChatMessagesResult: Result<[[LiveStreamChatMessage]], LiveApiError>?
  private let numberOfPeopleWatchingResult: Result<[Int], LiveApiError>?
  private let numberOfPeopleWatchingResultNever: Bool?
  private let scaleNumberOfPeopleWatchingResult: Result<[Int], LiveApiError>?
  private let scaleNumberOfPeopleWatchingResultNever: Bool?
  private let sendChatMessageResult: Result<[()], LiveApiError>?
  private let signInToFirebaseAnonymouslyResult: Result<[String], LiveApiError>?
  private let signInToFirebaseWithCustomTokenResult: Result<[String], LiveApiError>?
  private let subscribeToResult: Result<LiveStreamSubscribeEnvelope, LiveApiError>?

  internal init() {
    self.init(fetchEventResult: nil)
  }

  internal init(chatMessagesAddedResult: Result<[LiveStreamChatMessage], LiveApiError>? = nil,
                greenRoomOffStatusResult: Result<[Bool], LiveApiError>? = nil,
                fetchEventResult: Result<LiveStreamEvent, LiveApiError>? = nil,
                fetchEventsForProjectResult: Result<LiveStreamEventsEnvelope, LiveApiError>? = nil,
                fetchEventsResult: Result<[LiveStreamEvent], LiveApiError>? = nil,
                hlsUrlResult: Result<[String], LiveApiError>? = nil,
                incrementNumberOfPeopleWatchingResult: Result<[()], LiveApiError>? = nil,
                initialChatMessagesResult: Result<[[LiveStreamChatMessage]], LiveApiError>? = nil,
                numberOfPeopleWatchingResult: Result<[Int], LiveApiError>? = nil,
                numberOfPeopleWatchingResultNever: Bool? = nil,
                scaleNumberOfPeopleWatchingResult: Result<[Int], LiveApiError>? = nil,
                scaleNumberOfPeopleWatchingResultNever: Bool? = nil,
                sendChatMessageResult: Result<[()], LiveApiError>? = nil,
                signInToFirebaseAnonymouslyResult: Result<[String], LiveApiError>? = nil,
                signInToFirebaseWithCustomTokenResult: Result<[String], LiveApiError>? = nil,
                subscribeToResult: Result<LiveStreamSubscribeEnvelope, LiveApiError>? = nil) {
    self.chatMessagesAddedResult = chatMessagesAddedResult
    self.initialChatMessagesResult = initialChatMessagesResult
    self.greenRoomOffStatusResult = greenRoomOffStatusResult
    self.fetchEventResult = fetchEventResult
    self.fetchEventsForProjectResult = fetchEventsForProjectResult
    self.fetchEventsResult = fetchEventsResult
    self.hlsUrlResult = hlsUrlResult
    self.incrementNumberOfPeopleWatchingResult = incrementNumberOfPeopleWatchingResult
    self.numberOfPeopleWatchingResult = numberOfPeopleWatchingResult
    self.numberOfPeopleWatchingResultNever = numberOfPeopleWatchingResultNever
    self.scaleNumberOfPeopleWatchingResult = scaleNumberOfPeopleWatchingResult
    self.scaleNumberOfPeopleWatchingResultNever = scaleNumberOfPeopleWatchingResultNever
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

  func chatMessagesAdded(withPath path: String, addedSince timeInterval: TimeInterval) ->
    SignalProducer<LiveStreamChatMessage, LiveApiError> {
      if let error = self.chatMessagesAddedResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        self.chatMessagesAddedResult?.value ?? []
      )
  }

  func initialChatMessages(withPath path: String, limitedToLast limit: UInt) ->
    SignalProducer<[LiveStreamChatMessage], LiveApiError> {
      if let error = self.initialChatMessagesResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        self.initialChatMessagesResult?.value ?? []
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

    if self.numberOfPeopleWatchingResultNever == .some(true) {
      return SignalProducer.never
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

    if self.scaleNumberOfPeopleWatchingResultNever == .some(true) {
      return SignalProducer.never
    }

    return SignalProducer(
      self.scaleNumberOfPeopleWatchingResult?.value ?? []
    )
  }

  internal func sendChatMessage(withPath path: String, chatMessage message: NewLiveStreamChatMessageProtocol)
    -> SignalProducer<(), LiveApiError> {
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
