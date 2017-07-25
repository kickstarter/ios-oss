import Argo
import Curry
import Runes
import Foundation
import Prelude
import ReactiveSwift
import Result

private func parseJSONData(_ data: Data) -> Any? {
  return (try? JSONSerialization.jsonObject(with: data, options: []))
}

private let scheduler = QueueScheduler(qos: .background, name: "com.kickstarter.ksapi", targeting: nil)

internal extension URLSession {

  // Wrap an URLSession producer with error envelope logic.
  internal func rac_dataResponse(_ request: URLRequest, uploading file: (url: URL, name: String)? = nil)
    -> SignalProducer<Data, ErrorEnvelope> {

      let producer = file.map { self.rac_dataWithRequest(request, uploading: $0, named: $1) }
        ?? self.reactive.data(with: request)

      return producer
        .start(on: scheduler)
        .flatMapError { _ in SignalProducer(error: .couldNotParseErrorEnvelopeJSON) } // NSError
        .flatMap(.concat) { data, response -> SignalProducer<Data, ErrorEnvelope> in
          guard let response = response as? HTTPURLResponse else { fatalError() }

          guard
            (200..<300).contains(response.statusCode),
            let headers = response.allHeaderFields as? [String:String],
            let contentType = headers["Content-Type"], contentType.hasPrefix("application/json")
            else {

              print("[KsApi] Failure \(self.sanitized(request))")

              if let json = parseJSONData(data) {
                switch decode(json) as Decoded<ErrorEnvelope> {
                case let .success(envelope):
                  // Got the error envelope
                  return SignalProducer(error: envelope)
                case let .failure(error):
                  print("Argo decoding error envelope error: \(error)")
                  return SignalProducer(error: .couldNotDecodeJSON(error))
                }
              } else {
                print("Couldn't parse error envelope JSON.")
                return SignalProducer(error: .couldNotParseErrorEnvelopeJSON)
              }
            }

          print("[KsApi] Success \(self.sanitized(request))")
          return SignalProducer(value: data)
        }
  }

  // Converts an URLSessionTask into a signal producer of raw JSON data. If the JSON does not parse
  // successfully, an `ErrorEnvelope.errorJSONCouldNotParse()` error is emitted.
  internal func rac_JSONResponse(_ request: URLRequest, uploading file: (url: URL, name: String)? = nil)
    -> SignalProducer<Any, ErrorEnvelope> {

      return self.rac_dataResponse(request, uploading: file)
        .map(parseJSONData)
        .flatMap { json -> SignalProducer<Any, ErrorEnvelope> in
          guard let json = json else {
            return .init(error: .couldNotParseJSON)
          }
          return .init(value: json)
        }
  }

  // swiftlint:disable force_try
  fileprivate static let sanitationRules = [
    "oauth_token=[REDACTED]":
      try! NSRegularExpression(pattern: "oauth_token=([a-zA-Z0-9]*)", options: .caseInsensitive),
    "client_id=[REDACTED]":
      try! NSRegularExpression(pattern: "client_id=([a-zA-Z0-9]*)", options: .caseInsensitive),
    "access_token=[REDACTED]":
      try! NSRegularExpression(pattern: "access_token=([a-zA-Z0-9]*)", options: .caseInsensitive),
    "password=[REDACTED]":
      try! NSRegularExpression(pattern: "password=([a-zA-Z0-9]*)", options: .caseInsensitive)
    ]
  // swiftlint:enable force_try

  // Strips sensitive materials from the request, e.g. oauth token, client id, fb token, password, etc...
  fileprivate func sanitized(_ request: URLRequest) -> String {
    guard let urlString = request.url?.absoluteString else { return "" }

    return URLSession.sanitationRules.reduce(urlString) { accum, templateAndRule in
      let (template, rule) = templateAndRule
      let range = NSRange(location: 0, length: accum.characters.count)
      return rule.stringByReplacingMatches(in: accum,
                                           options: .withTransparentBounds,
                                           range: range,
                                           withTemplate: template)
    }
  }
}

private let defaultSessionError =
  NSError(domain: "com.kickstarter.KsApi.rac_dataWithRequest", code: 1, userInfo: nil)

private let boundary = "k1ck574r73r154c0mp4ny"

extension URLSession {
  // Returns a producer that will execute the given upload once for each invocation of start().
  fileprivate func rac_dataWithRequest(_ request: URLRequest, uploading file: URL, named name: String)
    -> SignalProducer<(Data, URLResponse), AnyError> {

      var mutableRequest = request

      guard
        let data = try? Data(contentsOf: file),
        let mime = file.imageMime ?? data.imageMime,
        let multipartHead = ("--\(boundary)\r\n"
          + "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(file.lastPathComponent)\"\r\n"
          + "Content-Type: \(mime)\r\n\r\n").data(using: .utf8),
        let multipartTail = "--\(boundary)--\r\n".data(using: .utf8)
        else { fatalError() }

      var body = Data()
      body.append(multipartHead)
      body.append(data)
      body.append(multipartTail)

      mutableRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      mutableRequest.httpBody = body

      return SignalProducer { observer, disposable in
        let task = self.dataTask(with: mutableRequest) { data, response, error in
          guard let data = data, let response = response else {
            observer.send(error: AnyError(error ?? defaultSessionError))
            return
          }
          observer.send(value: (data, response))
          observer.sendCompleted()
        }
        disposable += task.cancel
        task.resume()
      }
  }
}
