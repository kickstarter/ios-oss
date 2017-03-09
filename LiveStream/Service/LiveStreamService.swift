import Argo
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase
import ReactiveSwift

public struct LiveStreamService: LiveStreamServiceProtocol {
  public init() {
  }

  public func deleteDatabase() {
    guard LiveStreamService.getAppInstance() != nil else { return }
    LiveStreamService.firebaseApp()?.delete({ _ in })
  }

  public func fetchEvent(eventId: Int, uid: Int?, liveAuthToken: String?) ->
    SignalProducer<LiveStreamEvent, LiveApiError> {

      return SignalProducer { (observer, disposable) in
        let apiUrl = URL(string: Secrets.LiveStreams.endpoint)?
          .appendingPathComponent("\(eventId)")
        var components = apiUrl.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }

        components?.queryItems = []

        uid.map { uid in
          components?.queryItems?.append(URLQueryItem(name: "uid", value: "\(uid)"))
        }
        liveAuthToken.map { token in
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

  public func initializeDatabase(failed: (Void) -> Void,
                                 succeeded: (FIRDatabaseReference) -> Void) {

    guard let app = LiveStreamService.firebaseApp() else {
      failed()
      return
    }

    let databaseRef = FIRDatabase.database(app: app).reference()
    databaseRef.database.goOnline()

    succeeded(databaseRef)
  }

  public func signInAnonymously(completion: @escaping (String) -> Void) {
    LiveStreamService.firebaseAuth()?.signInAnonymously { user, _ in
      guard let id = user?.uid else { return }
      completion(id)
    }
  }

  public func signIn(withCustomToken customToken: String, completion: @escaping (String) -> Void) {
    LiveStreamService.firebaseAuth()?.signIn(withCustomToken: customToken) { user, _ in
      guard let id = user?.uid else { return }
      completion(id)
    }
  }

  public func signOut() {
    try? LiveStreamService.firebaseAuth()?.signOut()
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

  private static func start() {
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

  private static func firebaseApp() -> FIRApp? {
    guard let app = self.getAppInstance() else {
      self.start()
      return self.getAppInstance()
    }

    return app
  }

  private static func firebaseAuth() -> FIRAuth? {
    guard let app = self.firebaseApp() else { return nil }
    return FIRAuth(app: app)
  }

  private static func getAppInstance() -> FIRApp? {
    return FIRApp(named: Secrets.Firebase.Huzza.Production.appName)
  }
}

fileprivate func formData(withDictionary dictionary: [String:String]) -> String {
  let params = dictionary.flatMap { key, value -> String? in
    guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

    return "\(key)=\(value)"
  }

  return params.joined(separator: "&")
}
