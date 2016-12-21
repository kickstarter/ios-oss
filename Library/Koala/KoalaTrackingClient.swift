import KsApi
import Prelude
import Result

private let flushInterval = 60.0
private let chunkSize = 4

public final class KoalaTrackingClient: TrackingClientType {
  fileprivate let endpoint: Endpoint
  fileprivate let URLSession: URLSession
  fileprivate let queue = DispatchQueue(label: "com.kickstarter.KoalaTrackingClient")
  fileprivate var buffer: [[String:Any]] = []
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

  public func track(event: String, properties: [String:Any]) {
    #if DEBUG
      NSLog("[Koala Track]: \(event), properties: \(properties)")
    #endif

    self.queue.async {
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
    self.queue.async {
      if self.buffer.isEmpty { return }

      while !self.buffer.isEmpty {
        guard
          let result = KoalaTrackingClient.base64Payload(Array(self.buffer.prefix(chunkSize)))
            .flatMap(self.koalaURL)
            .flatMap(KoalaTrackingClient.koalaRequest)
            .flatMap(self.synchronousKoalaResult),
          case .success = result else { break }

        self.buffer.removeFirst(min(chunkSize, self.buffer.count))
      }
    }
  }

  fileprivate func save() {
    self.queue.async {
      guard !self.buffer.isEmpty, let file = self.fileName() else { return }

      NSKeyedArchiver.archiveRootObject(self.buffer, toFile: file)

      self.buffer.removeAll()
    }
  }

  fileprivate func load() {
    self.queue.async {
      guard
        let file = self.fileName(), FileManager.default.fileExists(atPath: file),
        let buffer = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? [[String:Any]]
        else { return }

      self.buffer = buffer + self.buffer

      _ = try? FileManager.default.removeItem(atPath: file)
    }
  }

  fileprivate static func base64Payload(_ payload: [Any]) -> String? {
    return (try? JSONSerialization.data(withJSONObject: payload, options: []))
      .map { $0.base64EncodedString(options: []) }
  }

  fileprivate func koalaURL(_ dataString: String) -> URL? {
    #if DEBUG
      if dataString.characters.count >= 10_000 {
        print("[Koala Error] Base64 payload is longer than 10,000 characters.")
      }
    #endif
    return URL(string: "\(self.endpoint.base)?data=\(dataString)")
  }

  fileprivate static func koalaRequest(_ url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    return request
  }

  fileprivate func synchronousKoalaResult(_ request: URLRequest) -> Result<HTTPURLResponse, NSError>? {
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
    self.queue.async {
      if self.taskId != UIBackgroundTaskInvalid {
        handler()
      }
    }
  }

  @objc fileprivate func applicationWillEnterForeground() {
    self.queue.async {
      guard self.taskId != UIBackgroundTaskInvalid else { return }
      UIApplication.shared.endBackgroundTask(self.taskId)
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
