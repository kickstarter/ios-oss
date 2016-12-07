import KsApi
import Prelude
import Result

private let flushInterval = 60.0
private let chunkSize = 4

public final class KoalaTrackingClient: TrackingClientType {
  private let endpoint: Endpoint
  private let URLSession: NSURLSession
  private let queue = dispatch_queue_create("com.kickstarter.KoalaTrackingClient", DISPATCH_QUEUE_SERIAL)
  private var buffer: [[String: AnyObject]] = []
  private var timer: NSTimer?
  private var taskId = UIBackgroundTaskInvalid

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

  public init(endpoint: Endpoint = .production, URLSession: NSURLSession = .sharedSession()) {
    self.endpoint = endpoint
    self.URLSession = URLSession

    let notifications = NSNotificationCenter.defaultCenter()
    notifications.addObserver(self,
                              selector: #selector(applicationDidBecomeActive),
                              name: UIApplicationDidBecomeActiveNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationDidEnterBackground),
                              name: UIApplicationDidEnterBackgroundNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillEnterForeground),
                              name: UIApplicationWillEnterForegroundNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillResignActive),
                              name: UIApplicationWillResignActiveNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillTerminate),
                              name: UIApplicationWillTerminateNotification, object: nil)

    self.load()
    self.startTimer()
  }

  public func track(event event: String, properties: [String: AnyObject]) {
    #if DEBUG
      NSLog("[Koala Track]: \(event), properties: \(properties)")
    #endif

    dispatch_async(self.queue) {
      self.buffer.append(["event": event, "properties": properties])
    }
  }

  private func startTimer() {
    self.timer = NSTimer.scheduledTimerWithTimeInterval(
      flushInterval, target: self, selector: #selector(flush), userInfo: nil, repeats: true
    )
  }

  private func stopTimer() {
    self.timer = nil
  }

  @objc private func flush() {
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

  private func save() {
    dispatch_async(self.queue) {
      guard !self.buffer.isEmpty, let file = self.fileName() else { return }

      NSKeyedArchiver.archiveRootObject(self.buffer, toFile: file)

      self.buffer.removeAll()
    }
  }

  private func load() {
    dispatch_async(self.queue) {
      guard
        let file = self.fileName()
        where NSFileManager.defaultManager().fileExistsAtPath(file),
        let buffer = NSKeyedUnarchiver.unarchiveObjectWithFile(file) as? [[String: AnyObject]]
        else { return }

      self.buffer = buffer + self.buffer

      _ = try? NSFileManager.defaultManager().removeItemAtPath(file)
    }
  }

  private static func base64Payload(payload: [AnyObject]) -> String? {
    return (try? NSJSONSerialization.dataWithJSONObject(payload, options: []))
      .map { $0.base64EncodedStringWithOptions([]) }
  }

  private func koalaURL(dataString: String) -> NSURL? {
    #if DEBUG
      if dataString.characters.count >= 10_000 {
        print("[Koala Error] Base64 payload is longer than 10,000 characters.")
      }
    #endif
    return NSURL(string: "\(self.endpoint.base)?data=\(dataString)")
  }

  private static func koalaRequest(url: NSURL) -> NSURLRequest {
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    return request
  }

  private func synchronousKoalaResult(request: NSURLRequest) -> Result<NSHTTPURLResponse, NSError>? {
    var result: Result<NSHTTPURLResponse, NSError>?
    let semaphore = dispatch_semaphore_create(0)

    self.URLSession.dataTaskWithRequest(request) { _, response, err in
      defer { dispatch_semaphore_signal(semaphore) }

      if let httpResponse = response as? NSHTTPURLResponse {
        #if DEBUG
          NSLog("[Koala Status Code]: \(httpResponse.statusCode)")
        #endif
        result = Result(value: httpResponse)
      }

      if let err = err {
        result = Result(error: err)
      }
    }.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    if result == nil {
      NSLog("[Koala Request] response/error result unexpectedly nil")
      assertionFailure()
    }

    return result
  }

  private func fileName() -> String? {
    return NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
      .map { ($0 as NSString).stringByAppendingPathComponent("koala.plist") }
  }
}

extension KoalaTrackingClient {
  @objc private func applicationDidBecomeActive() {
    self.startTimer()
  }

  @objc private func applicationDidEnterBackground() {
    let handler = {
      UIApplication.sharedApplication().endBackgroundTask(self.taskId)
      self.taskId = UIBackgroundTaskInvalid
    }

    self.taskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(handler)
    self.flush()
    self.save()
    dispatch_async(self.queue) {
      if self.taskId != UIBackgroundTaskInvalid {
        handler()
      }
    }
  }

  @objc private func applicationWillEnterForeground() {
    dispatch_async(self.queue) {
      guard self.taskId != UIBackgroundTaskInvalid else { return }
      UIApplication.sharedApplication().endBackgroundTask(self.taskId)
      self.taskId = UIBackgroundTaskInvalid
    }
  }

  @objc private func applicationWillResignActive() {
    self.stopTimer()
  }

  @objc private func applicationWillTerminate() {
    self.save()
  }
}
