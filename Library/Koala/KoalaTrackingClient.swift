import Crashlytics
import KsApi
import Prelude
import Result

private let flushInterval = 60.0
private let chunkSize = 4

public final class KoalaTrackingClient: TrackingClientType {
  fileprivate let endpoint: Endpoint
  fileprivate let URLSession: URLSession
  fileprivate let queue = DispatchQueue(label: "com.kickstarter.KoalaTrackingClient")
  fileprivate var buffer: [[String: Any]] = []
  fileprivate var timer: Timer?
  fileprivate var taskId = UIBackgroundTaskIdentifier.invalid

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
                              name: UIApplication.didBecomeActiveNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationDidEnterBackground),
                              name: UIApplication.didEnterBackgroundNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillEnterForeground),
                              name: UIApplication.willEnterForegroundNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillResignActive),
                              name: UIApplication.willResignActiveNotification, object: nil)
    notifications.addObserver(self,
                              selector: #selector(applicationWillTerminate),
                              name: UIApplication.willTerminateNotification, object: nil)

    self.load()
    self.startTimer()
  }

  public func track(event: String, properties: [String: Any]) {
    print("🐨 [Koala Track]: \(event), properties: \(properties)")

    self.queue.async {
      Answers.logCustomEvent(withName: event, customAttributes: nil)
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
          nil != KoalaTrackingClient.base64Payload(Array(self.buffer.prefix(chunkSize)))
            .flatMap(self.koalaURL)
            .flatMap(KoalaTrackingClient.koalaRequest)
            .flatMap(self.synchronousKoalaResult)
          else { break }

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
        let buffer = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? [[String: Any]]
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
    if dataString.count >= 10_000 {
      print("🐨 [Koala Error]: Base64 payload is longer than 10,000 characters.")
    }
    return URL(string: "\(self.endpoint.base)?data=\(dataString)")
  }

  fileprivate static func koalaRequest(_ url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    return request
  }

  fileprivate func synchronousKoalaResult(_ request: URLRequest) -> HTTPURLResponse? {
    var result: HTTPURLResponse?
    let semaphore = DispatchSemaphore(value: 0)

    self.URLSession.dataTask(with: request) { _, response, _ in
      defer { semaphore.signal() }

      if let httpResponse = response as? HTTPURLResponse {
        print("🐨 [Koala Status Code]: \(httpResponse.statusCode)")

        result = httpResponse
      }

    }.resume()
    _ = semaphore.wait(timeout: .distantFuture)

    if result == nil {
      NSLog("[Koala Request] response/error result unexpectedly nil")
    }

    return result
  }

  fileprivate func fileName() -> String? {
    return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
      .flatMap { URL(string: $0)?.appendingPathComponent("koala.plist").absoluteString }
  }
}

extension KoalaTrackingClient {
  @objc fileprivate func applicationDidBecomeActive() {
    self.startTimer()
  }

  @objc fileprivate func applicationDidEnterBackground() {
    let handler = {
      UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.taskId.rawValue))
      self.taskId = UIBackgroundTaskIdentifier.invalid
    }

    self.taskId = UIApplication.shared.beginBackgroundTask(expirationHandler: handler)
    self.flush()
    self.save()
    self.queue.async {
      if self.taskId != UIBackgroundTaskIdentifier.invalid {
        handler()
      }
    }
  }

  @objc fileprivate func applicationWillEnterForeground() {
    self.queue.async {
      guard self.taskId != UIBackgroundTaskIdentifier.invalid else { return }
      UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.taskId.rawValue))
      self.taskId = UIBackgroundTaskIdentifier.invalid
    }
  }

  @objc fileprivate func applicationWillResignActive() {
    self.stopTimer()
  }

  @objc fileprivate func applicationWillTerminate() {
    self.save()
  }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
