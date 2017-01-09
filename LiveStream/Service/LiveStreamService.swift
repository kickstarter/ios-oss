import Argo
import ReactiveCocoa

public struct LiveStreamService: LiveStreamServiceProtocol {
  public init() {
  }

  public func fetchEvent(eventId eventId: Int, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError> {

    return SignalProducer { (observer, disposable) in
      let uidString = uid
        .flatMap { "?uid=\($0)" }
        .coalesceWith("")

      let urlString = "\(Secrets.LiveStreams.endpoint)/\(eventId)\(uidString)"
      guard let url = NSURL(string: urlString) else {
        observer.sendFailed(.invalidEventId)
        return
      }

      let urlSession = NSURLSession(configuration: .defaultSessionConfiguration())

      let task = urlSession.dataTaskWithURL(url) { data, _, error in
        guard error == nil else {
          observer.sendFailed(.genericFailure)
          return
        }

        let event = data
          .flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
          .map(JSON.init)
          .map(LiveStreamEvent.decode)
          .flatMap { $0.value }
          .map(Event<LiveStreamEvent, LiveApiError>.Next)
          .coalesceWith(.Failed(.genericFailure))

        observer.action(event)
        observer.sendCompleted()
      }

      task.resume()

      disposable.addDisposable({
        task.cancel()
        observer.sendInterrupted()
      })
    }
  }

  public func subscribeTo(eventId eventId: Int, uid: Int, isSubscribed: Bool)
    -> SignalProducer<Bool, LiveApiError> {

      return SignalProducer { (observer, disposable) in

        let urlString = "\(Secrets.LiveStreams.endpoint)/\(eventId)/subscribe"
        guard let url = NSURL(string: urlString) else {
          observer.sendFailed(.invalidEventId)
          return
        }

        let urlSession = NSURLSession(configuration: .defaultSessionConfiguration())

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = "uid=\(uid)&subscribe=\(String(!isSubscribed))"
          .dataUsingEncoding(NSUTF8StringEncoding)

        let task = urlSession.dataTaskWithRequest(request) { data, _, error in
          let result = data
            .flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
            .map { _ in !isSubscribed }
            .coalesceWith(isSubscribed)

          observer.sendNext(result)
          observer.sendCompleted()
        }

        task.resume()

        disposable.addDisposable({
          task.cancel()
          observer.sendInterrupted()
        })
      }
  }
}
