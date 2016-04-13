import class Foundation.NSURLSession
import class Foundation.NSJSONSerialization
import class Foundation.NSDate
import class Foundation.NSMutableURLRequest
import class Foundation.NSURLRequest
import class Foundation.NSURL
import class Foundation.NSURLSessionDataTask
import class Foundation.NSHTTPURLResponse
import var Foundation.NSUTF8StringEncoding

public final class KoalaTrackingClient: TrackingClientType {
  private let URLSession: NSURLSession
  private let endpoint: Endpoint

  public enum Endpoint: String {
    case Production = "production"
    case Staging = "staging"
  }

  public init(endpoint: Endpoint = .Production, URLSession: NSURLSession = .sharedSession()) {
    self.endpoint = endpoint
    self.URLSession = URLSession
  }

  public func track(event event: String, properties: [String: AnyObject]) {
    // TODO: Don't log in production
    print("[Koala] Track: \(event), properties: \(properties)")
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

    // TODO: Make a queue of events that are flushed every X seconds.
    task?.resume()
  }

  // Extract the koala endpoint URL from the `koala-endpoint.config` file in the bundle.
  private lazy var endpointBase: String = AppEnvironment.current.mainBundle
    .pathForResource("koala-endpoint", ofType: "config")
    .flatMap { try? String(contentsOfFile: $0) }
    .flatMap { $0.dataUsingEncoding(NSUTF8StringEncoding) }
    .flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
    .flatMap { $0 as? [String:String] }
    .flatMap { $0[self.endpoint.rawValue] } ?? ""

  private static func base64Payload(payload: [AnyObject]) -> String? {
    return (try? NSJSONSerialization.dataWithJSONObject(payload, options: []))
      .map { $0.base64EncodedStringWithOptions([]) }
  }

  private func koalaURL(dataString: String) -> NSURL? {
    return NSURL(string: "\(self.endpointBase)?data=\(dataString)")
  }

  private static func koalaRequest(url: NSURL) -> NSURLRequest {
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    return request
  }

  private func koalaTask(request: NSURLRequest) -> NSURLSessionDataTask {
    return URLSession.dataTaskWithRequest(request) { _, response, err in
      guard let response = response as? NSHTTPURLResponse else { return }
      print("[Koala] Status code: \(response.statusCode)")
    }
  }
}
