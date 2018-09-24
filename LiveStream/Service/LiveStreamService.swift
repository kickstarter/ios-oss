import Argo
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase
import ReactiveSwift

private var firebaseApp: FIRApp?
private var firebaseAuth: FIRAuth?
private var firebaseDb: FIRDatabase?
private var firebaseDbRef: FIRDatabaseReference?

extension FIRDataSnapshot: FirebaseDataSnapshotType {}

private let timestampKey = "timestamp"

private func startFirebase() {
  let options: FIROptions = FIROptions(googleAppID: Secrets.Firebase.Huzza.Production.googleAppID,
                                       bundleID: Secrets.Firebase.Huzza.Production.bundleID,
                                       gcmSenderID: Secrets.Firebase.Huzza.Production.gcmSenderID,
                                       apiKey: Secrets.Firebase.Huzza.Production.apiKey,
                                       clientID: Secrets.Firebase.Huzza.Production.clientID,
                                       trackingID: "",
                                       androidClientID: "",
                                       databaseURL: Secrets.Firebase.Huzza.Production.databaseURL,
                                       storageBucket: Secrets.Firebase.Huzza.Production.storageBucket,
                                       deepLinkURLScheme: "")

  FIRApp.configure(withName: Secrets.Firebase.Huzza.Production.appName, options: options)
}

public struct LiveStreamService: LiveStreamServiceProtocol {
  private let backgroundScheduler = QueueScheduler(
    qos: .background,
    name: "com.kickstarter.liveStreamBackgroundQueue",
    targeting: nil
  )

  public init() {
  }

  public func setup() {
    guard FIRApp(named: Secrets.Firebase.Huzza.Production.appName) == nil else { return }

    startFirebase()
    firebaseApp = FIRApp(named: Secrets.Firebase.Huzza.Production.appName)
    firebaseAuth = firebaseApp.flatMap(FIRAuth.init(app:))
    firebaseDb = firebaseApp.map(FIRDatabase.database(app:))
    firebaseDbRef = firebaseDb?.reference()
  }

  public func fetchEvent(eventId: Int,
                         uid: Int?,
                         liveAuthToken: String?) -> SignalProducer<LiveStreamEvent, LiveApiError> {

    return SignalProducer { (observer, disposable) in
      let apiUrl = URL(string: Secrets.LiveStreams.endpoint)?
        .appendingPathComponent("\(eventId)")
      var components = apiUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }

      components?.queryItems = []

      uid.doIfSome { uid in
        components?.queryItems?.append(URLQueryItem(name: "uid", value: "\(uid)"))
      }
      liveAuthToken.doIfSome { token in
        components?.queryItems?.append(URLQueryItem(name: "h", value: "\(token)"))
      }

      guard let url = components?.url else {
        observer.send(error: .invalidRequest)
        return
      }

      let urlSession = URLSession(configuration: .default)

      let task = urlSession.dataTask(with: url) { data, _, error in
        guard error == nil else {
          observer.send(error: .genericFailure)
          return
        }

        let event = data
          .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
          .map(JSON.init)
          .map(LiveStreamEvent.decode)
          .flatMap { $0.value }
          .map(Signal<LiveStreamEvent, LiveApiError>.Event.value)
          .coalesceWith(.failed(.genericFailure))

        observer.send(event)
        observer.sendCompleted()
      }

      task.resume()

      disposable.observeEnded {
        task.cancel()
        observer.sendInterrupted()
      }
    }
  }

  public func fetchEvents() -> SignalProducer<[LiveStreamEvent], LiveApiError> {

    return SignalProducer { (observer, disposable) in

      guard let url = URL(string: Secrets.LiveStreams.Api.base)?
        .appendingPathComponent("ksr-streams") else {
          observer.send(error: .genericFailure)
          return
      }

      let urlSession = URLSession(configuration: .default)

      let task = urlSession.dataTask(with: url) { data, _, error in
        guard error == nil else {
          observer.send(error: .genericFailure)
          return
        }

        let event = data
          .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
          .map(JSON.init)
          .map([LiveStreamEvent].decode)
          .flatMap { $0.value }
          .map(Signal<[LiveStreamEvent], LiveApiError>.Event.value)
          .coalesceWith(.failed(.genericFailure))

        observer.send(event)
        observer.sendCompleted()
      }

      task.resume()

      disposable.observeEnded {
        task.cancel()
        observer.sendInterrupted()
      }
    }
  }

  public func fetchEvents(forProjectId projectId: Int, uid: Int?)
    -> SignalProducer<LiveStreamEventsEnvelope, LiveApiError> {

      return SignalProducer { (observer, disposable) in
        let apiUrl = URL(string: Secrets.LiveStreams.Api.base)?
          .appendingPathComponent("projects")
          .appendingPathComponent("\(projectId)")
        var components = apiUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        components?.queryItems = uid.map { uid in [URLQueryItem(name: "uid", value: "\(uid)")] }

        guard let url = components?.url else {
          observer.send(error: .invalidRequest)
          return
        }

        let urlSession = URLSession(configuration: .default)

        let task = urlSession.dataTask(with: url) { data, _, error in
          guard error == nil else {
            observer.send(error: .genericFailure)
            return
          }

          let envelope = data
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
            .map(JSON.init)
            .map(LiveStreamEventsEnvelope.decode)
            .flatMap { $0.value }
            .map(Signal<LiveStreamEventsEnvelope, LiveApiError>.Event.value)
            .coalesceWith(.failed(.genericFailure))

          observer.send(envelope)
          observer.sendCompleted()
        }

        task.resume()

        disposable.observeEnded {
          task.cancel()
          observer.sendInterrupted()
        }
      }
  }

  public func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool)
    -> SignalProducer<LiveStreamSubscribeEnvelope, LiveApiError> {

      return SignalProducer { (observer, disposable) in
        let apiUrl = URL(string: Secrets.LiveStreams.endpoint)?
          .appendingPathComponent("\(eventId)")
          .appendingPathComponent("subscribe")
        let components = apiUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }

        guard let url = components?.url else {
          observer.send(error: .invalidRequest)
          return
        }

        let urlSession = URLSession(configuration: .default)

        let params = [
          "uid": String(uid),
          "subscribe": String(!isSubscribed)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = formData(withDictionary: params).data(using: .utf8)

        let task = urlSession.dataTask(with: request) { data, _, _ in
          let envelope = data
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
            .map(JSON.init)
            .map(LiveStreamSubscribeEnvelope.decode)
            .flatMap { $0.value }
            .map(Signal<LiveStreamSubscribeEnvelope, LiveApiError>.Event.value)
            .coalesceWith(.failed(.genericFailure))

          observer.send(envelope)
          observer.sendCompleted()
        }

        task.resume()

        disposable.observeEnded {
          task.cancel()
          observer.sendInterrupted()
        }
      }
  }

  // MARK: Firebase

  public func initialChatMessages(withPath path: String, limitedToLast limit: UInt)
    -> SignalProducer<[LiveStreamChatMessage], LiveApiError> {

      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.send(.failed(.failedToInitializeFirebase))
          return
        }

        let query = ref.child(path)
          .queryOrdered(byChild: timestampKey)
          .queryLimited(toLast: limit)

        query.observe(.value, with: { snapshot in
          let chatMessages = (snapshot.children.allObjects as? [FIRDataSnapshot] ?? [])
            .map([LiveStreamChatMessage].decode)
            .flatMap { $0.value }
            .map(Signal<[LiveStreamChatMessage], LiveApiError>.Event.value)
            .coalesceWith(.failed(.chatMessageDecodingFailed))

          observer.send(chatMessages)
          observer.sendCompleted()
        })

        disposable.observeEnded {
          query.removeAllObservers()
          observer.sendInterrupted()
        }
        }
        .start(on: self.backgroundScheduler)
  }

  public func chatMessagesAdded(withPath path: String, addedSince timeInterval: TimeInterval)
    -> SignalProducer<LiveStreamChatMessage, LiveApiError> {

      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.send(.failed(.failedToInitializeFirebase))
          return
        }

        let query = ref.child(path)
          .queryOrdered(byChild: timestampKey)
          .queryStarting(
            atValue: timeInterval,
            childKey: timestampKey
        )

        query.observe(.childAdded, with: { snapshot in
          let tryChatMessage = (snapshot as FIRDataSnapshot?)
            .flatMap { $0 }
            .map(LiveStreamChatMessage.decode)
            .flatMap { $0.value }
            .map(Signal<LiveStreamChatMessage, LiveApiError>.Event.value)

          guard let chatMessage = tryChatMessage else { return }

          observer.send(chatMessage)
        })

        disposable.observeEnded {
          query.removeAllObservers()
          observer.sendInterrupted()
        }
      }
  }

  public func greenRoomOffStatus(withPath path: String) -> SignalProducer<Bool, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      let query = ref.child(path).queryOrderedByKey()

      query.observe(.value, with: { snapshot in
        let value = snapshot.value
          .flatMap { $0 as? Bool }
          .map(Signal<Bool, LiveApiError>.Event.value)
          .coalesceWith(.failed(.snapshotDecodingFailed(path: path)))

        observer.send(value)
      })

      disposable.observeEnded {
        query.removeAllObservers()
        observer.sendInterrupted()
      }
    }
  }

  public func hlsUrl(withPath path: String) -> SignalProducer<String, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      let query = ref.child(path).queryOrderedByKey()

      query.observe(.value, with: { snapshot in
        let value = snapshot.value
          .flatMap { $0 as? String }
          .map(Signal<String, LiveApiError>.Event.value)
          .coalesceWith(.failed(.snapshotDecodingFailed(path: path)))

        observer.send(value)
      })

      disposable.observeEnded {
        query.removeAllObservers()
        observer.sendInterrupted()
      }
    }
  }

  public func numberOfPeopleWatching(withPath path: String) -> SignalProducer<Int, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      let query = ref.child(path).queryOrderedByKey()

      query.observe(.value, with: { snapshot in
        let value = snapshot.value
          .flatMap { $0 as? NSDictionary }
          .map { $0.allKeys.count }
          .map(Signal<Int, LiveApiError>.Event.value)
          .coalesceWith(.failed(.snapshotDecodingFailed(path: path)))

        observer.send(value)
      })

      disposable.observeEnded {
        query.removeAllObservers()
        observer.sendInterrupted()
      }
    }
  }

  public func incrementNumberOfPeopleWatching(withPath path: String) -> SignalProducer<(), LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      let presenceRef = ref.child(path)
      presenceRef.setValue(true)
      presenceRef.onDisconnectRemoveValue()

      observer.send(Signal<(), LiveApiError>.Event.value(()))

      disposable.observeEnded {
        presenceRef.removeAllObservers()
        observer.sendInterrupted()
      }
    }
  }

  public func scaleNumberOfPeopleWatching(withPath path: String) -> SignalProducer<Int, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      let query = ref.child(path).queryOrderedByKey()

      query.observe(.value, with: { snapshot in
        let value = snapshot.value
          .flatMap { $0 as? Int }
          .map(Signal<Int, LiveApiError>.Event.value)
          .coalesceWith(.failed(.snapshotDecodingFailed(path: path)))

        observer.send(value)
      })

      disposable.observeEnded {
        query.removeAllObservers()
        observer.sendInterrupted()
      }
    }
  }

  public func signInToFirebaseAnonymously() -> SignalProducer<String, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let auth = firebaseAuth else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      auth.signInAnonymously { user, _ in
        let value = user
          .map { $0.uid }
          .map(Signal<String, LiveApiError>.Event.value)
          .coalesceWith(.failed(.firebaseAnonymousAuthFailed))

        observer.send(value)
        observer.sendCompleted()
      }

      disposable.observeEnded {
        observer.sendInterrupted()
      }
    }
  }

  public func signInToFirebase(withCustomToken customToken: String) -> SignalProducer<String, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let auth = firebaseAuth else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      auth.signIn(withCustomToken: customToken) { user, _ in
        let value = user
          .map { $0.uid }
          .map(Signal<String, LiveApiError>.Event.value)
          .coalesceWith(.failed(.firebaseCustomTokenAuthFailed))

        observer.send(value)
        observer.sendCompleted()
      }

      disposable.observeEnded {
        observer.sendInterrupted()
      }
    }
  }

  public func sendChatMessage(
    withPath path: String,
    chatMessage message: NewLiveStreamChatMessageProtocol) -> SignalProducer<(), LiveApiError> {

    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.send(.failed(.failedToInitializeFirebase))
        return
      }

      let messageWithTimestamp = message.toFirebaseDictionary().withAllValuesFrom([
        timestampKey: FIRServerValue.timestamp()
        ])

      let chatRef = ref.child(path).childByAutoId()
      chatRef.setValue(messageWithTimestamp) { (error, _) in
        guard error == nil else {
          observer.send(error: .sendChatMessageFailed)
          return
        }

        observer.sendCompleted()
      }

      disposable.observeEnded {
        chatRef.removeAllObservers()
        observer.sendInterrupted()
      }
    }
  }
}

private func formData(withDictionary dictionary: [String: String]) -> String {
  let params = dictionary.compactMap { key, value -> String? in
    guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

    return "\(key)=\(value)"
  }

  return params.joined(separator: "&")
}
