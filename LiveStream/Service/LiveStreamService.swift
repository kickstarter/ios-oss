import Argo
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase
import ReactiveSwift

public struct LiveStreamService: LiveStreamServiceProtocol {
  public init() {
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

  public func firebaseApp() -> SignalProducer<FirebaseAppType, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      let tryApp = firebaseAppInstance()

      if tryApp == nil {
        startFirebase()
      }

      guard let app = tryApp else {
        observer.send(error: .failedToInitializeFirebase)
        return
      }

      observer.send(value: app)
      observer.sendCompleted()//fixme: should this complete?

      disposable.add({
        app.delete({ _ in })//fixme: would have to ensure this isn't duplicated
        observer.sendInterrupted()
      })
    }
  }

  public func firebaseAuth(withApp app: FirebaseAppType) -> SignalProducer<FirebaseAuthType, LiveApiError> {
    return SignalProducer { (observer, disposable) in
      guard let app = app as? FIRApp else { return }

      guard let auth = FIRAuth(app: app) else {
        observer.send(error: .firebaseAnonymousAuthFailed)
        return
      }

      observer.send(value: auth)
      observer.sendCompleted()

      disposable.add({
        try? auth.signOut()
        observer.sendInterrupted()
      })
    }
  }

  public func greenRoomStatus(withDatabaseRef dbRef: FirebaseDatabaseReferenceType,
                              refConfig: FirebaseRefConfig) -> SignalProducer<Bool?, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = dbRef as? FIRDatabaseReference else { return }

        let query = ref.child(refConfig.ref)
          .queryOrderedByKey()

        query.observe(.value, with: { snapshot in
          observer.send(value: snapshot.value as? Bool)
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }

  public func signInToFirebaseAnonymously(withAuth auth: FirebaseAuthType) ->
    SignalProducer<String, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let auth = auth as? FIRAuth else { return }

        auth.signInAnonymously { user, _ in
          guard let id = user?.uid else {
            observer.send(error: .firebaseAnonymousAuthFailed)
            return
          }

          observer.send(value: id)
          observer.sendCompleted()
        }

        disposable.add({
          try? auth.signOut()
          observer.sendInterrupted()
        })
      }
  }

  public func signIn(withAuth auth: FirebaseAuthType, customToken: String) ->
    SignalProducer<String, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let auth = auth as? FIRAuth else { return }

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

  //fixme: this can't really error out but stuff earlier up the chain can?
  public func firebaseDatabaseRef(withApp app: FirebaseAppType) ->
    SignalProducer<FirebaseDatabaseReferenceType, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let app = app as? FIRApp else { return }//fixme: or possibly error out here?

        let db = FIRDatabase.database(app: app)
        db.goOnline()//fixme: can this be called multiple times?

        observer.send(value: db.reference())
        observer.sendCompleted()

        disposable.add({
          db.goOffline()
          observer.sendInterrupted()
        })
      }
  }

  public func chatMessageSnapshotsValue(withDatabaseRef dbRef: FirebaseDatabaseReferenceType,
                                        refConfig: FirebaseRefConfig, limitedToLast limit: UInt) ->
    SignalProducer<FirebaseDataSnapshotType, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = dbRef as? FIRDatabaseReference else { return }
        guard let orderBy = refConfig.orderBy as String? else { return }//fixme: send error?

        let query = ref.child(refConfig.ref)
          .queryOrdered(byChild: orderBy)
          .queryLimited(toLast: limit)

        query.observe(.childAdded, with: { snapshot in
          observer.send(value: snapshot)
          observer.sendCompleted()
        })

        disposable.add({
          query.removeAllObservers()
          observer.sendInterrupted()
        })
      }
  }

  //fixme: potentially only this one is public and internally chained to above producer?
  public func chatMessageSnapshotsAdded(withDatabaseRef dbRef: FirebaseDatabaseReferenceType,
                                   refConfig: FirebaseRefConfig,
                                   addedSinceTimeInterval timeInterval: TimeInterval) ->
    SignalProducer<FirebaseDataSnapshotType, LiveApiError> {
      return SignalProducer { (observer, disposable) in
        guard let ref = dbRef as? FIRDatabaseReference else { return }
        guard let orderBy = refConfig.orderBy as String? else { return }//fixme: send error?

        let query = ref.child(refConfig.ref)
          .queryOrdered(byChild: orderBy)
          .queryStarting(
            atValue: refConfig.startingAtValue,
            childKey: refConfig.startingAtChildKey
        )

        query.observe(.childAdded, with: { snapshot in
          observer.send(value: snapshot)
        })

        disposable.add({
          query.removeAllObservers()
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

private func firebaseAuth() -> FIRAuth? {
  guard let app = firebaseAppInstance() else { return nil }
  return FIRAuth(app: app)
}

private func firebaseAppInstance() -> FIRApp? {
  return FIRApp(named: Secrets.Firebase.Huzza.Production.appName)
}

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
