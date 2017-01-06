import FirebaseAnalytics
import FirebaseDatabase
import ReactiveCocoa
import Result
import Argo

public enum LiveApiError: ErrorType {
  case genericFailure
  case invalidEventId
  case invalidJson
}

public class KsLiveApp {

  private static func start() {
    let options =
      FIROptions(googleAppID: Secrets.Firebase.Huzza.Production.googleAppID,
                 bundleID: Secrets.Firebase.Huzza.Production.bundleID,
                 GCMSenderID: Secrets.Firebase.Huzza.Production.gcmSenderID,
                 APIKey: Secrets.Firebase.Huzza.Production.apiKey,
                 clientID: Secrets.Firebase.Huzza.Production.clientID,
                 trackingID: "",
                 androidClientID: "",
                 databaseURL: Secrets.Firebase.Huzza.Production.databaseURL,
                 storageBucket: Secrets.Firebase.Huzza.Production.storageBucket,
                 deepLinkURLScheme: "")

    FIRApp.configureWithName(Secrets.Firebase.Huzza.Production.appName, options: options)

    // FIXME: make sure we can get rid of this:
//    if let app = FIRApp(named: Secrets.Firebase.Huzza.appName) {
//      FIRDatabase.database(app: app).persistenceEnabled = true
//    }
  }

  //swiftlint:disable force_unwrapping
  // FIXME: make this return optional and have the views/vms handle the `nil` case to show an error
  public static func firebaseApp() -> FIRApp {
    guard let app = FIRApp(named: Secrets.Firebase.Huzza.Production.appName) else {
      self.start()
      return FIRApp(named: Secrets.Firebase.Huzza.Production.appName)!
    }

    return app
  }
  //swiftlint:enable force_unwrapping

  public static func apiUrl() -> String {
    return Secrets.LiveStreams.endpoint
  }

  // MARK: LiveStreamEvent object

  // FIXME: use a custom error type insteadof NSError
  public static func retrieveEvent(eventId: String, uid: Int?)
    -> SignalProducer<LiveStreamEvent, LiveApiError> {

      return SignalProducer { (observer, disposable) in

        // FIXME: gotta unwrap the optional otherwise it shows up as "?uid=Optional(1520421473)"
        let urlString = "\(KsLiveApp.apiUrl())/\(eventId)\(uid != nil ? "?uid=\(uid)" : "")"
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

  // FIXME: apply some of the ideas of the above to clean this up
  public static func subscribe(eventId: String, uid: Int, subscribe: Bool)
    -> SignalProducer<Bool, LiveApiError> {

      return SignalProducer { (observer, disposable) in

        guard let url = NSURL(
          string: "\(KsLiveApp.apiUrl())/\(eventId)/subscribe") else {
            observer.sendFailed(.invalidEventId)
            return
        }

        let urlSession = NSURLSession(configuration: .defaultSessionConfiguration())

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = "uid=\(uid)&subscribe=\(String(!subscribe))"
          .dataUsingEncoding(NSUTF8StringEncoding)

        let task = urlSession.dataTaskWithRequest(request,
          completionHandler: { (data, _, error) in
            if let _ = error {
              observer.sendFailed(.genericFailure)
            } else {
              guard let _ = data.flatMap ({ try? NSJSONSerialization.JSONObjectWithData($0, options: []) })
                else {
                  observer.sendNext(subscribe)
                  observer.sendCompleted()

                  return
              }

              observer.sendNext(!subscribe)
              observer.sendCompleted()
            }
        })

        task.resume()
        
        disposable.addDisposable({
          task.cancel()
          observer.sendInterrupted()
        })
      }
  }
}
