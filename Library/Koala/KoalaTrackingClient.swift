import KsApi
import Prelude
import Result

private let flushInterval = 60.0
private let chunkSize = 4

public final class KoalaTrackingClient: TrackingClientType {
  fileprivate let endpoint: Endpoint
  fileprivate let URLSession: URLSession
  fileprivate let queue = dispatch_queue_create("com.kickstarter.KoalaTrackingClient", DISPATCH_QUEUE_SERIAL)
  fileprivate var buffer: [[String: AnyObject]] = []
  fileprivate var timer: Timer?
  fileprivate var taskId = UIBackgroundTaskInvalid

  public enum Endpoint {
    case staging
    case production

    var base: String {
      switch self {
      case .staging:
        return Secrets.KoalaEndpoint.staging
      case .production:
        return Secrets.KoalaEndpoint.production
      }
    }
  }

  public init(endpoint: Endpoint = .production, URLSession: URLSession = .shared) {
    self.endpoint = endpoint
    self.URLSession = URLSession

    let notifications = NotificationCenter.default
    notifications.addObserver(self,
                              selector: #selector(applicationDidBecomeActive),
                              name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationDidEnterBackground),
                              name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillEnterForeground),
                              name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillResignActive),
                              name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillTerminate),
                              name: NSNotification.Name.UIApplicationWillTerminate, object: nil)

    self.load()
    self.startTimer()
  }

  public func track(event: String, properties: [String: AnyObject]) {
    #if DEBUG
      NSLog("[Koala Track]: \(event), properties: \(properties)")
    #endif

    dispatch_async(self.queue) {
      self.buffer.append(["event": event, "properties": properties])
    }
  }

  fileprivate func startTimer() {
    self.timer = Timer.scheduledTimer(
      timeInterval: flushInterval, target: self, selector: #selector(flush), userInfo: nil, repeats: true
    )
  }

  fileprivate func stopTimer() {
    self.timer = nil
  }

  @objc fileprivate func flush() {
    dispatch_async(self.queue) {
      if self.buffer.isEmpty { return }

      while !self.buffer.isEmpty {
        guard
          let result = KoalaTrackingClient.base64Payload(Array(self.buffer.prefix(chunkSize)))
            .flatMap(self.koalaURL)
            .flatMap(KoalaTrackingClient.koalaRequest)
            .flatMap(self.synchronousKoalaResult),
          case .Success = result else { break }

        self.buffer.removeFirst(min(chunkSize, self.buffer.count))
      }
    }
  }

  fileprivate func save() {
    dispatch_async(self.queue) {
      guard !self.buffer.isEmpty, let file = self.fileName() else { return }

      NSKeyedArchiver.archiveRootObject(self.buffer, toFile: file)

      self.buffer.removeAll()
    }
  }

  fileprivate func load() {
    dispatch_async(self.queue) {
      guard
        let file = self.fileName(), NSFileManager.defaultManager().fileExistsAtPath(file),
        let buffer = NSKeyedUnarchiver.unarchiveObjectWithFile(file) as? [[String: AnyObject]]
        else { return }

      self.buffer = buffer + self.buffer

      _ = try? NSFileManager.defaultManager().removeItemAtPath(file)
    }
  }

  fileprivate static func base64Payload(_ payload: [AnyObject]) -> String? {
    return (try? JSONSerialization.dataWithJSONObject(payload, options: []))
      .map { $0.base64EncodedStringWithOptions([]) }
  }

  fileprivate func koalaURL(_ dataString: String) -> NSURL? {
    #if DEBUG
      if dataString.characters.count >= 10_000 {
        print("[Koala Error] Base64 payload is longer than 10,000 characters.")
      }
    #endif
    return NSURL(string: "\(self.endpoint.base)?data=\(dataString)")
  }

  fileprivate static func koalaRequest(_ url: NSURL) -> NSURLRequest {
    let request = NSMutableURLRequest(url: url as URL)
    request.httpMethod = "POST"
    return request
  }

  fileprivate func synchronousKoalaResult(_ request: NSURLRequest) -> Result<HTTPURLResponse, NSError>? {
    var result: Result<HTTPURLResponse, NSError>?
    let semaphore = DispatchSemaphore(value: 0)

    self.URLSession.dataTask(with: request as URLRequest) { _, response, err in
      defer { semaphore.signal() }

      if let httpResponse = response as? HTTPURLResponse {
        #if DEBUG
          NSLog("[Koala Status Code]: \(httpResponse.statusCode)")
        #endif
        result = Result(value: httpResponse)
      }

      if let err = err {
        result = Result(error: err)
      }
    }.resume()
    semaphore.wait(timeout: dispatch_time_t(DispatchTime.distantFuture))

    if result == nil {
      NSLog("[Koala Request] response/error result unexpectedly nil")
      assertionFailure()
    }

    return result
  }

  fileprivate func fileName() -> String? {
    return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
      .map { ($0 as NSString).appendingPathComponent("koala.plist") }
  }
}

extension KoalaTrackingClient {
  @objc fileprivate func applicationDidBecomeActive() {
    self.startTimer()
  }

  @objc fileprivate func applicationDidEnterBackground() {
    let handler = {
      UIApplication.shared.endBackgroundTask(self.taskId)
      self.taskId = UIBackgroundTaskInvalid
    }

    self.taskId = UIApplication.shared.beginBackgroundTask(expirationHandler: handler)
    self.flush()
    self.save()
    dispatch_async(self.queue) {
      if self.taskId != UIBackgroundTaskInvalid {
        handler()
      }
    }
  }

  @objc fileprivate func applicationWillEnterForeground() {
    dispatch_async(self.queue) {
      guard self.taskId != UIBackgroundTaskInvalid else { return }
      UIApplication.sharedApplication().endBackgroundTask(self.taskId)
      self.taskId = UIBackgroundTaskInvalid
    }
  }

  @objc fileprivate func applicationWillResignActive() {
    self.stopTimer()
  }

  @objc fileprivate func applicationWillTerminate() {
    self.save()
  }
}
