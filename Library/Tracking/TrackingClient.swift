import KsApi
import Prelude

private let flushInterval = 60.0
private let chunkSize = 4

public final class TrackingClient: TrackingClientType {
  fileprivate let config: TrackingClientConfiguration
  fileprivate let queue: DispatchQueue
  fileprivate var buffer: [[String: Any]] = []
  fileprivate var timer: Timer?
  fileprivate var taskId = UIBackgroundTaskIdentifier.invalid
  fileprivate let urlSession: URLSession = .shared

  public init(_ configuration: TrackingClientConfiguration) {
    self.config = configuration
    self.queue = DispatchQueue(label: "com.kickstarter.\(self.config.identifier)TrackingClient")

    let notifications = NotificationCenter.default
    notifications.addObserver(
      self,
      selector: #selector(TrackingClient.applicationDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification, object: nil
    )
    notifications.addObserver(
      self,
      selector: #selector(TrackingClient.applicationDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification, object: nil
    )
    notifications.addObserver(
      self,
      selector: #selector(TrackingClient.applicationWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification, object: nil
    )
    notifications.addObserver(
      self,
      selector: #selector(TrackingClient.applicationWillResignActive),
      name: UIApplication.willResignActiveNotification, object: nil
    )
    notifications.addObserver(
      self,
      selector: #selector(TrackingClient.applicationWillTerminate),
      name: UIApplication.willTerminateNotification, object: nil
    )

    self.load()
    self.startTimer()
  }

  public func track(event: String, properties: [String: Any]) {
    if AppEnvironment.current.environmentVariables.isKoalaTrackingEnabled {
      print("\(self.config.identifier.emoji) [\(self.config.identifier) Track]: \(event), properties: \(properties)")

      self.queue.async {
        self.buffer.append(self.config.recordDictionary(event, properties))
      }
    }
  }

  fileprivate func startTimer() {
    self.timer = Timer.scheduledTimer(
      timeInterval: flushInterval, target: self, selector: #selector(self.flush), userInfo: nil, repeats: true
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
          self.payload(Array(self.buffer.prefix(chunkSize)))
          .flatMap(self.request)
          .flatMap(self.synchronousResult) != nil
        else { break }

        self.buffer.removeFirst(min(chunkSize, self.buffer.count))
      }
    }
  }

  fileprivate func save() {
    self.queue.async {
      guard !self.buffer.isEmpty, let file = self.fileName() else { return }

      do {
        let url = URL(fileURLWithPath: file)
        let data = try NSKeyedArchiver.archivedData(withRootObject: self.buffer, requiringSecureCoding: false)
        try data.write(to: url)
        print("\(self.config.identifier.emoji)🔵 \(self.plistName()) successfully saved.")
      } catch {
        print("\(self.config.identifier.emoji)🔴 Failed to save \(self.plistName()): \(error)")
      }
      self.buffer.removeAll()
    }
  }

  fileprivate func load() {
    self.queue.async {
      guard
        let file = self.fileName(), FileManager.default.fileExists(atPath: file),
        let buffer = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
          Data(contentsOf: URL(fileURLWithPath: file))
        ) as? [[String: Any]]
      else { return }

      self.buffer = buffer + self.buffer

      _ = try? FileManager.default.removeItem(atPath: file)
    }
  }

  fileprivate func payload(_ payload: Any) -> Data? {
    guard JSONSerialization.isValidJSONObject(payload) else {
      assertionFailure("🔴 Payload is not a valid JSON object")

      return nil
    }

    return try? JSONSerialization.data(
      withJSONObject: self.config.envelope(payload),
      options: []
    )
  }

  fileprivate func request(_ data: Data) -> URLRequest? {
    return self.config.request(self.config, AppEnvironment.current.environmentType, data)
  }

  fileprivate func synchronousResult(_ request: URLRequest) -> HTTPURLResponse? {
    var result: HTTPURLResponse?
    let semaphore = DispatchSemaphore(value: 0)

    self.urlSession.dataTask(with: request) { _, response, _ in
      defer { semaphore.signal() }

      if let httpResponse = response as? HTTPURLResponse {
        print("\(self.config.identifier.emoji) [\(self.config.identifier) Status Code]: \(httpResponse.statusCode)")

        result = httpResponse
      }
    }
    .resume()

    _ = semaphore.wait(timeout: .distantFuture)

    if result == nil {
      NSLog("[\(self.config.identifier) Request] response/error result unexpectedly nil")
    }

    return result
  }

  private func plistName() -> String {
    return "\(self.config.identifier.rawValue.lowercased()).plist"
  }

  fileprivate func fileName() -> String? {
    return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
      .flatMap { URL(string: $0)?.appendingPathComponent(self.plistName()).absoluteString }
  }
}

extension TrackingClient {
  @objc fileprivate func applicationDidBecomeActive() {
    self.startTimer()
  }

  @objc fileprivate func applicationDidEnterBackground() {
    let handler = {
      UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: self.taskId.rawValue))
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
      UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: self.taskId.rawValue))
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
