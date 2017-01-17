import Argo
import FirebaseDatabase
import ReactiveSwift

public struct LiveStreamService: LiveStreamServiceProtocol {
  public init() {
  }

  public func fetchEvent(eventId: Int, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError> {

    return SignalProducer { (observer, disposable) in
      let uidString = uid
        .flatMap { "?uid=\($0)" }
        .coalesceWith("")

      let urlString = "\(Secrets.LiveStreams.endpoint)/\(eventId)\(uidString)"
      guard let url = URL(string: urlString) else {
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

  public func initializeDatabase(userId: Int?, failed: (Void) -> Void, succeeded: (FIRDatabaseReference) -> Void) {

    guard let app = KsLiveApp.firebaseApp() else {
      failed()
      return
    }

    let databaseRef = FIRDatabase.database(app: app).reference()
    databaseRef.database.goOnline()

    succeeded(databaseRef)
  }

  public func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool) -> SignalProducer<Bool, LiveApiError> {

      return SignalProducer { (observer, disposable) in

        let urlString = "\(Secrets.LiveStreams.endpoint)/\(eventId)/subscribe"
        guard let url = URL(string: urlString) else {
          observer.send(error: .invalidEventId)
          return
        }

        let urlSession = URLSession(configuration: .default)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "uid=\(uid)&subscribe=\(String(!isSubscribed))".data(using: .utf8)

        let task = urlSession.dataTask(with: request) { data, _, _ in
          let result = data
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
            .map { _ in !isSubscribed }
            .coalesceWith(isSubscribed)

          observer.send(value: result)
          observer.sendCompleted()
        }

        task.resume()

        disposable.add({
          task.cancel()
          observer.sendInterrupted()
        })
      }
  }
}
