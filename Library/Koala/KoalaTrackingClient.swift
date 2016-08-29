import Foundation

public final class KoalaTrackingClient: TrackingClientType {
  private let endpoint: Endpoint
  private let URLSession: NSURLSession

  public enum Endpoint {
    case staging
    case production

    var base: String {
      switch self {
      case .staging:
        return "https://***REMOVED***/native/track"
      case .production:
        return "https://***REMOVED***/native/track"
      }
    }
  }

  public init(endpoint: Endpoint = .production, URLSession: NSURLSession = .sharedSession()) {
    self.endpoint = endpoint
    self.URLSession = URLSession
  }

  public func track(event event: String, properties: [String: AnyObject]) {
    #if DEBUG
    NSLog("[Koala Track]: \(event), properties: \(properties)")
    #endif
    self.track(event: event, properties: properties, time: NSDate())
  }

  private func track(event event: String, properties: [String: AnyObject], time: NSDate) {
    let payload = [
      [ "event": event,
        "properties": properties ]
    ]

    let task = KoalaTrackingClient.base64Payload(payload)
      .flatMap(koalaURL)
      .flatMap(KoalaTrackingClient.koalaRequest)
      .map(koalaTask)

    task?.resume()
  }

  private static func base64Payload(payload: [AnyObject]) -> String? {
    return (try? NSJSONSerialization.dataWithJSONObject(payload, options: []))
      .map { $0.base64EncodedStringWithOptions([]) }
  }

  private func koalaURL(dataString: String) -> NSURL? {
    return NSURL(string: "\(self.endpoint.base)?data=\(dataString)")
  }

  private static func koalaRequest(url: NSURL) -> NSURLRequest {
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    return request
  }

  private func koalaTask(request: NSURLRequest) -> NSURLSessionDataTask {
    return URLSession.dataTaskWithRequest(request) { _, response, err in
      #if DEBUG
        let httpResponses = response as? NSHTTPURLResponse
        NSLog("[Koala Status code]: \(httpResponses?.statusCode)")
      #endif
    }
  }
}
