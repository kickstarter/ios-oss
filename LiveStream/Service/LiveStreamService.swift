import Argo
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase
import ReactiveSwift

private var firebaseApp: FIRApp?
private var firebaseAuth: FIRAuth?
private var firebaseDb: FIRDatabase?
private var firebaseDbRef: FIRDatabaseReference?

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

  public func fetchEvent(eventId: Int, uid: Int?,
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
          observer.send(error: .invalidEventId)
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
            .map(Event<LiveStreamEvent, LiveApiError>.value)
            .coalesceWith(.failed(.genericFailure))

          observer.action(event)
          observer.sendCompleted()
        }

        task.resume()

        disposable.add({
          task.cancel()
          observer.sendInterrupted()
        })
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
          .map(Event<[LiveStreamEvent], LiveApiError>.value)
          .coalesceWith(.failed(.genericFailure))

        observer.action(event)
        observer.sendCompleted()
      }

      task.resume()

      disposable.add({
        task.cancel()
        observer.sendInterrupted()
      })
    }
  }

  public func fetchEvents(forProjectId projectId: Int, uid: Int?) ->
    SignalProducer<LiveStreamEventsEnvelope, LiveApiError> {

      return SignalProducer { (observer, disposable) in
        let apiUrl = URL(string: Secrets.LiveStreams.Api.base)?
          .appendingPathComponent("projects")
          .appendingPathComponent("\(projectId)")
        var components = apiUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        components?.queryItems = uid.map { uid in [URLQueryItem(name: "uid", value: "\(uid)")] }

        guard let url = components?.url else {
          observer.send(error: .invalidProjectId)
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
            .map(Event<LiveStreamEventsEnvelope, LiveApiError>.value)
            .coalesceWith(.failed(.genericFailure))

          observer.action(envelope)
          observer.sendCompleted()
        }

        task.resume()

        disposable.add({
          task.cancel()
          observer.sendInterrupted()
        })
      }
  }

  public func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool) ->
    SignalProducer<LiveStreamSubscribeEnvelope, LiveApiError> {

      return SignalProducer { (observer, disposable) in
        let apiUrl = URL(string: Secrets.LiveStreams.endpoint)?
          .appendingPathComponent("\(eventId)")
          .appendingPathComponent("subscribe")
        let components = apiUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }

        guard let url = components?.url else {
          observer.send(error: .invalidEventId)
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
            .map(Event<LiveStreamSubscribeEnvelope, LiveApiError>.value)
            .coalesceWith(.failed(.genericFailure))

          observer.action(envelope)
          observer.sendCompleted()
        }

        task.resume()

        disposable.add({
          task.cancel()
          observer.sendInterrupted()
        })
      }
  }

  // MARK: Firebase

  public func chatMessageSnapshotsValue(withPath path: String,
                                        limitedToLast limit: UInt) ->
    SignalProducer<[LiveStreamChatMessage], LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        let query = ref.child(path)
          .queryOrdered(byChild: timestampKey)
          .queryLimited(toLast: limit)

        //fixme: or fix me not?
        query.observe(.value, with: { snapshot in
          let chatMessages = (snapshot.children.allObjects as? [FIRDataSnapshot] ?? [])
            .map([LiveStreamChatMessage].decode)
            .flatMap { $0.value }
            .map(Event<[LiveStreamChatMessage], LiveApiError>.value)
            .coalesceWith(.failed(.snapshotDecodingFailed))

          observer.action(chatMessages)
          observer.sendCompleted()
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
        }
        .start(on: self.backgroundScheduler)
  }

  public func chatMessageSnapshotsAdded(withPath path: String,
                                        addedSinceTimeInterval timeInterval: TimeInterval) ->
    SignalProducer<LiveStreamChatMessage, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        let query = ref.child(path)
          .queryOrdered(byChild: timestampKey)
          .queryStarting(
            atValue: timeInterval,
            childKey: timestampKey
        )

        query.observe(.childAdded, with: { snapshot in
          let chatMessage = (snapshot as FIRDataSnapshot?)
            .flatMap { $0 }
            .map(LiveStreamChatMessage.decode)
            .flatMap { $0.value }
            .map(Event<LiveStreamChatMessage, LiveApiError>.value)
            .coalesceWith(.failed(.snapshotDecodingFailed))

          observer.action(chatMessage)
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }

  public func greenRoomOffStatus(withPath path: String) ->
    SignalProducer<Bool, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        let query = ref.child(path).queryOrderedByKey()

        query.observe(.value, with: { snapshot in
          let value = snapshot.value
            .flatMap { $0 as? Bool }
            .map(Event<Bool, LiveApiError>.value)
            .coalesceWith(.failed(.snapshotDecodingFailed))

          observer.action(value)
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }

  public func hlsUrl(withPath path: String) -> SignalProducer<String, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.action(.failed(.failedToInitializeFirebase))
        return
      }

      let query = ref.child(path).queryOrderedByKey()

      query.observe(.value, with: { snapshot in
        let value = snapshot.value
          .flatMap { $0 as? String }
          .map(Event<String, LiveApiError>.value)
          .coalesceWith(.failed(.snapshotDecodingFailed))

        observer.action(value)
      })

      disposable.add({
        query.removeAllObservers()
        observer.sendInterrupted()
      })
    }
  }

  public func numberOfPeopleWatching(withPath path: String) ->
    SignalProducer<Int, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let ref = firebaseDbRef else {
        observer.action(.failed(.failedToInitializeFirebase))
        return
      }

      let query = ref.child(path).queryOrderedByKey()

      query.observe(.value, with: { snapshot in
        let value = snapshot.value
          .flatMap { $0 as? NSDictionary }
          .map { $0.allKeys.count }
          .map(Event<Int, LiveApiError>.value)
          .coalesceWith(.failed(.snapshotDecodingFailed))

        observer.action(value)
      })

      disposable.add({
        query.removeAllObservers()
        observer.sendInterrupted()
      })
    }
  }

  public func incrementNumberOfPeopleWatching(withPath path: String) ->
    SignalProducer<(), LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        let presenceRef = ref.child(path)
        presenceRef.setValue(true)
        presenceRef.onDisconnectRemoveValue()

        observer.action(Event<(), LiveApiError>.value(()))

        disposable.add({
          presenceRef.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }

  public func scaleNumberOfPeopleWatching(withPath path: String) ->
    SignalProducer<Int, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        let query = ref.child(path).queryOrderedByKey()

        query.observe(.value, with: { snapshot in
          let value = snapshot.value
            .flatMap { $0 as? Int }
            .map(Event<Int, LiveApiError>.value)
            .coalesceWith(.failed(.snapshotDecodingFailed))

          observer.action(value)
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }

  public func signInToFirebaseAnonymously() ->
    SignalProducer<String, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let auth = firebaseAuth else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        auth.signInAnonymously { user, _ in
          let value = user
            .map { $0.uid }
            .map(Event<String, LiveApiError>.value)
            .coalesceWith(.failed(.firebaseAnonymousAuthFailed))

          observer.action(value)
          observer.sendCompleted()
        }

        disposable.add({
          observer.sendInterrupted()
        })
      }
  }

  public func signInToFirebase(withCustomToken customToken: String) ->
    SignalProducer<String, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let auth = firebaseAuth else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        auth.signIn(withCustomToken: customToken) { user, _ in
          let value = user
            .map { $0.uid }
            .map(Event<String, LiveApiError>.value)
            .coalesceWith(.failed(.firebaseCustomTokenAuthFailed))

          observer.action(value)
          observer.sendCompleted()
        }

        disposable.add({
          observer.sendInterrupted()
        })
      }
  }

  public func sendChatMessage(withPath path: String,
                              chatMessage message: NewLiveStreamChatMessage) ->
    SignalProducer<(), LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.action(.failed(.failedToInitializeFirebase))
          return
        }

        let messageWithTimestamp = message.toFirebaseDictionary().withAllValuesFrom([
          LiveStreamChatMessageDictionaryKey.timestamp.rawValue: FIRServerValue.timestamp()
          ])

        let chatRef = ref.child(path).childByAutoId()
        chatRef.setValue(messageWithTimestamp)

        observer.action(Event<(), LiveApiError>.value(()))
        observer.sendCompleted()

        disposable.add({
          chatRef.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }
}

private func formData(withDictionary dictionary: [String:String]) -> String {
  let params = dictionary.flatMap { key, value -> String? in
    guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

    return "\(key)=\(value)"
  }

  return params.joined(separator: "&")
}
