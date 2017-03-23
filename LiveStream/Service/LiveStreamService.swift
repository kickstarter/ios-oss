import Argo
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase
import ReactiveSwift

private var firebaseApp: FIRApp?
private var firebaseAuth: FIRAuth?
private var firebaseDb: FIRDatabase?
private var firebaseDbRef: FIRDatabaseReference?

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

  public init() {
  }

  func setup() {
    if FIRApp(named: Secrets.Firebase.Huzza.Production.appName) == nil { startFirebase() }

    firebaseApp = FIRApp(named: Secrets.Firebase.Huzza.Production.appName)
    firebaseAuth = firebaseApp.flatMap(FIRAuth.init(app:))
    firebaseDb = firebaseApp.map(FIRDatabase.database(app:))
    firebaseDbRef = firebaseDb?.reference()
  }

  public func fetchEvent(eventId: Int, uid: Int?, liveAuthToken: String?) ->
    SignalProducer<LiveStreamEvent, LiveApiError> {

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

  public func chatMessageSnapshotsValue(withRefConfig refConfig: FirebaseRefConfig,
                                        limitedToLast limit: UInt) ->
    SignalProducer<[LiveStreamChatMessage], LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.send(error: .failedToInitializeFirebase)
          return
        }

        guard let orderBy = refConfig.orderBy as String? else {
          observer.send(error: .genericFailure)
          return
        }

        let query = ref.child(refConfig.ref)
          .queryOrdered(byChild: orderBy)
          .queryLimited(toLast: limit)

        query.observe(.value, with: { snapshot in
          let chatMessages = snapshot.value
            .map(JSON.init)
            .map([LiveStreamChatMessage].decode)
            .flatMap { $0.value }
            .map(Event<[LiveStreamChatMessage], LiveApiError>.value)
            .coalesceWith(.failed(.genericFailure))

          observer.action(chatMessages)
          observer.sendCompleted()
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
      }
//        .start(on: QueueScheduler(
//          qos: .background,
//          name: "com.kickstarter.liveStreamChatDecodingQueue",
//          targeting: nil
//        ))
  }

  public func chatMessageSnapshotsAdded(withRefConfig refConfig: FirebaseRefConfig,
                                        addedSinceTimeInterval timeInterval: TimeInterval) ->
    SignalProducer<LiveStreamChatMessage, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.send(error: .failedToInitializeFirebase)
          return
        }

        guard let orderBy = refConfig.orderBy as String? else {
          observer.send(error: .genericFailure)
          return
        }

        let query = ref.child(refConfig.ref)
          .queryOrdered(byChild: orderBy)
          .queryStarting(
            atValue: refConfig.startingAtValue,
            childKey: refConfig.startingAtChildKey
        )

        query.observe(.childAdded, with: { snapshot in
          let chatMessage = snapshot.value
            .map(JSON.init)
            .map(LiveStreamChatMessage.decode)
            .flatMap { $0.value }
            .map(Event<LiveStreamChatMessage, LiveApiError>.value)
            .coalesceWith(.failed(.genericFailure))

          observer.action(chatMessage)
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }

  public func greenRoomStatus(withRefConfig refConfig: FirebaseRefConfig) ->
    SignalProducer<Bool?, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = firebaseDbRef else {
          observer.send(error: .failedToInitializeFirebase)
          return
        }

        let query = ref.child(refConfig.ref).queryOrderedByKey()

        query.observe(.value, with: { snapshot in
          observer.send(value: snapshot.value as? Bool)//fixme: cast and return nil or error out?
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
          observer.send(error: .failedToInitializeFirebase)
          return
        }

        auth.signInAnonymously { user, _ in
          guard let id = user?.uid else {
            observer.send(error: .firebaseAnonymousAuthFailed)
            return
          }

          observer.send(value: id)
          observer.sendCompleted()
        }

        disposable.add({
          observer.sendInterrupted()
        })
      }
  }

  public func signIn(withCustomToken customToken: String) ->
    SignalProducer<String, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let auth = firebaseAuth else {
          observer.send(error: .failedToInitializeFirebase)
          return
        }

        auth.signIn(withCustomToken: customToken) { user, _ in
          guard let id = user?.uid else {
            observer.send(error: .firebaseCustomTokenAuthFailed)
            return
          }

          observer.send(value: id)
          observer.sendCompleted()
        }

        disposable.add({
          observer.sendInterrupted()
        })
      }
  }
}

fileprivate func formData(withDictionary dictionary: [String:String]) -> String {
  let params = dictionary.flatMap { key, value -> String? in
    guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

    return "\(key)=\(value)"
  }

  return params.joined(separator: "&")
}
