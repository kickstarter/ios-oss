import FirebaseAnalytics
import FirebaseDatabase
import ReactiveCocoa
import Result
import Argo

public class KsLiveApp {

  public static func start() {
    let options =
      FIROptions(googleAppID: Secrets.Firebase.Huzza.googleAppID,
                 bundleID: Secrets.Firebase.Huzza.bundleID,
                 GCMSenderID: Secrets.Firebase.Huzza.gcmSenderID,
                 APIKey: Secrets.Firebase.Huzza.apiKey,
                 clientID: Secrets.Firebase.Huzza.clientID,
                 trackingID: "",
                 androidClientID: "",
                 databaseURL: Secrets.Firebase.Huzza.databaseURL,
                 storageBucket: Secrets.Firebase.Huzza.storageBucket,
                 deepLinkURLScheme: "")

    FIRApp.configureWithName(Secrets.Firebase.Huzza.appName, options: options)
    if let app = FIRApp(named: Secrets.Firebase.Huzza.appName) {
      FIRDatabase.database(app: app).persistenceEnabled = true
    }
  }

  //swiftlint:disable force_unwrapping
  public static func firebaseApp() -> FIRApp {
    guard let app = FIRApp(named: Secrets.Firebase.Huzza.appName) else {
      self.start()
      return FIRApp(named: Secrets.Firebase.Huzza.appName)!
    }

    return app
  }
  //swiftlint:enable force_unwrapping

  public static func apiUrl() -> String {
    return Secrets.LiveStreams.endpoint
  }

  public static func appBundle() -> NSBundle {
    return NSBundle(forClass: KsLiveApp.self)
  }

  // MARK: LiveStreamEvent object

  public static func retrieveEvent(eventId: String, uid: Int?) ->
    SignalProducer<LiveStreamEvent, NSError> {
    return SignalProducer { (observer, disposable) in

      guard let url = NSURL(
        string: "\(KsLiveApp.apiUrl())/\(eventId)\(uid != nil ? "?uid=\(uid)" : "")") else {
          observer.sendFailed(NSError(domain: "", code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Invalid LiveStreamEvent ID"]))
          return
      }

      let urlSession = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

      let task = urlSession.dataTaskWithURL(url,
        completionHandler: { (data, response, error) in
          if let error = error {
            observer.sendFailed(error)
          } else {
            let eventJson = data.flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
            let eventDecode = eventJson.flatMap({ (json) -> LiveStreamEvent? in
              let event = LiveStreamEvent.decode(JSON.init(json))
              switch event {
              case .Success(let event):
                return event
              case .Failure(let error):
                observer.sendFailed(NSError(domain: "", code: 0,
                  userInfo: [NSLocalizedDescriptionKey: error.description]))
              }

              return nil
            })

            guard let event = eventDecode else {
              observer.sendFailed(NSError(domain: "", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Error retrieving LiveStreamEvent info"]))
              return
            }

            observer.sendNext(event)
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

  public static func subscribe(eventId: String, uid: Int, subscribe: Bool) ->
    SignalProducer<Bool, NSError> {
    return SignalProducer { (observer, disposable) in

      guard let url = NSURL(
        string: "\(KsLiveApp.apiUrl())/\(eventId)/subscribe") else {
          observer.sendFailed(NSError(domain: "", code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Invalid LiveStreamEvent ID"]))
          return
      }

      let urlSession = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      request.HTTPBody = "uid=\(uid)&subscribe=\(String(!subscribe))"
        .dataUsingEncoding(NSUTF8StringEncoding)

      let task = urlSession.dataTaskWithRequest(request,
        completionHandler: { (data, response, error) in
          if let error = error {
            observer.sendFailed(error)
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
