import Argo
import Curry
import Foundation
import Prelude
import ReactiveSwift
import Runes

private func parseJSONData(_ data: Data) -> Any? {
  return (try? JSONSerialization.jsonObject(with: data, options: []))
}

private let scheduler = QueueScheduler(qos: .background, name: "com.kickstarter.ksapi", targeting: nil)

internal extension URLSession {
  // Wrap an URLSession producer with Graph error envelope logic.
  func rac_graphDataResponse(_ request: URLRequest)
    -> SignalProducer<Data, GraphError> {
    let producer = self.reactive.data(with: request)

    return producer
      .start(on: scheduler)
      .flatMapError { error -> SignalProducer<(Data, URLResponse), GraphError> in
        print("🔴 [KsApi] Request Error \(error.localizedDescription)")

        return .init(error: GraphError.requestError(error, nil))
      }
      .flatMap(.concat) { data, response -> SignalProducer<Data, GraphError> in
        guard let response = response as? HTTPURLResponse else { fatalError() }

        guard self.isValidResponse(response: response) else {
          print("🔴 [KsApi] HTTP Failure \(self.sanitized(request))")

          return self.decodeGraphErrors(from: data)
            .flatMap { data in
              SignalProducer<Data, GraphError>(
                error: .jsonDecodingError(
                  responseString: String(data: data, encoding: .utf8),
                  error: nil
                )
              )
            }
        }

        print("🔵 [KsApi] HTTP Success \(self.sanitized(request))")

        return self.decodeGraphErrors(from: data)
          .flatMap { data in
            SignalProducer<Data, GraphError>(value: data)
          }
      }
  }

  private func decodeGraphErrors(from data: Data) -> SignalProducer<Data, GraphError> {
    // Decode errors if any
    let decodedErrorEnvelope = try? JSONDecoder().decode(GraphResponseErrorEnvelope.self, from: data)

    guard let error = decodedErrorEnvelope?.errors?.first else {
      return .init(value: data)
    }

    print("🔴 [KsApi] Graph Error \(error.message)")

    return .init(error: GraphError.decodeError(error))
  }

  private func isValidResponse(response: HTTPURLResponse) -> Bool {
    guard (200..<300).contains(response.statusCode),
      let headers = response.allHeaderFields as? [String: String],
      let contentType = headers["Content-Type"], contentType.hasPrefix("application/json") else {
      return false
    }

    return true
  }

  // Wrap an URLSession producer with error envelope logic.
  func rac_dataResponse(_ request: URLRequest, uploading file: (url: URL, name: String)? = nil)
    -> SignalProducer<Data, ErrorEnvelope> {
    let producer = file.map { self.rac_dataWithRequest(request, uploading: $0, named: $1) }
      ?? self.reactive.data(with: request)

    print("⚪️ [KsApi] Starting request \(self.sanitized(request))")

    return producer
      .start(on: scheduler)
      .flatMapError { _ in SignalProducer(error: .couldNotParseErrorEnvelopeJSON) } // NSError
      .flatMap(.concat) { data, response -> SignalProducer<Data, ErrorEnvelope> in
        guard let response = response as? HTTPURLResponse else { fatalError() }

        guard self.isValidResponse(response: response) else {
          if let json = parseJSONData(data) {
            switch decode(json) as Decoded<ErrorEnvelope> {
            case let .success(envelope):
              // Got the error envelope
              print("🔴 [KsApi] Failure \(self.sanitized(request)) \n Error - \(envelope)")

              return SignalProducer(error: envelope)
            case let .failure(error):
              print("🔴 [KsApi] Failure \(self.sanitized(request)) \n Argo decoding error - \(error)")
              return SignalProducer(error: .couldNotDecodeJSON(error))
            }

          } else {
            print("🔴 [KsApi] Failure \(self.sanitized(request))")

            return SignalProducer(error: .couldNotParseErrorEnvelopeJSON)
          }
        }

        print("🔵 [KsApi] Success \(self.sanitized(request))")
        return SignalProducer(value: data)
      }
  }

  // Converts an URLSessionTask into a signal producer of raw JSON data. If the JSON does not parse
  // successfully, an `ErrorEnvelope.errorJSONCouldNotParse()` error is emitted.
  func rac_JSONResponse(_ request: URLRequest, uploading file: (url: URL, name: String)? = nil)
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

  // Strips sensitive materials from the request, e.g. oauth token, client id, fb token, password, etc...
  fileprivate func sanitized(_ request: URLRequest) -> String {
    guard let urlString = request.url?.absoluteString else { return "" }

    return URLSession.sanitationRules.reduce(urlString) { accum, templateAndRule in
      let (template, rule) = templateAndRule
      let range = NSRange(location: 0, length: accum.count)
      return rule.stringByReplacingMatches(
        in: accum,
        options: .withTransparentBounds,
        range: range,
        withTemplate: template
      )
    }
  }
}

private let defaultSessionError =
  NSError(domain: "com.kickstarter.KsApi.rac_dataWithRequest", code: 1, userInfo: nil)

private let boundary = "k1ck574r73r154c0mp4ny"

extension URLSession {
  // Returns a producer that will execute the given upload once for each invocation of start().
  fileprivate func rac_dataWithRequest(_ request: URLRequest, uploading file: URL, named name: String)
    -> SignalProducer<(Data, URLResponse), Error> {
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
          observer.send(error: error ?? defaultSessionError)
          return
        }
        observer.send(value: (data, response))
        observer.sendCompleted()
      }
      disposable.observeEnded {
        task.cancel()
      }
      task.resume()
    }
  }
}
