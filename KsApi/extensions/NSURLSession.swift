import Combine
import Foundation
import Prelude
import ReactiveSwift

private func parseJSONData(_ data: Data) -> Any? {
  return (try? JSONSerialization.jsonObject(with: data, options: []))
}

private let scheduler = QueueScheduler(qos: .background, name: "com.kickstarter.ksapi", targeting: nil)

internal extension URLSession {
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
    let producer = file.map { self.rac_requestWithFileUpload(request, uploading: $0, named: $1) }
      ?? self.reactive.data(with: request)

    print("⚪️ [KsApi] Starting request \(self.sanitized(request))")

    return producer
      .start(on: scheduler)
      .flatMapError { _ in SignalProducer(error: .couldNotParseErrorEnvelopeJSON) } // NSError
      .flatMap(.concat) { data, response -> SignalProducer<Data, ErrorEnvelope> in
        guard let response = response as? HTTPURLResponse else { fatalError() }

        guard self.isValidResponse(response: response) else {
          if let json = parseJSONData(data) as? [String: Any] {
            do {
              let envelope: ErrorEnvelope = try ErrorEnvelope.decodeJSONDictionary(json)
              print("🔴 [KsApi] Failure \(self.sanitized(request)) \n Error - \(envelope)")
              return SignalProducer(error: envelope)
            } catch {
              print("🔴 [KsApi] Failure \(self.sanitized(request)) \n Decoding error - \(error)")
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

  func combine_dataResponse(_ request: URLRequest,
                            uploading file: (url: URL, name: String)? = nil) -> AnyPublisher<
    Data,
                              ErrorEnvelope
                            > {
    let producer = file != nil ? self
      .combine_requestWithFileUpload(request, uploading: file!.url, named: file!.name) :
      DataTaskPublisher(request: request, session: self).eraseToAnyPublisher()

    return producer
      .mapError { _ in ErrorEnvelope.couldNotParseErrorEnvelopeJSON }
      .flatMap { (data: Data, response: URLResponse) -> AnyPublisher<Data, ErrorEnvelope> in
        guard let response = response as? HTTPURLResponse else {
          fatalError()
        }

        guard self.isValidResponse(response: response) else {
          if let json = parseJSONData(data) as? [String: Any] {
            do {
              let envelope: ErrorEnvelope = try ErrorEnvelope.decodeJSONDictionary(json)
              return Fail<Data, ErrorEnvelope>(error: envelope).eraseToAnyPublisher()
            } catch {
              return Fail<Data, ErrorEnvelope>(error: .couldNotDecodeJSON(error)).eraseToAnyPublisher()
            }

          } else {
            return Fail<Data, ErrorEnvelope>(error: .couldNotParseErrorEnvelopeJSON).eraseToAnyPublisher()
          }
        }
        return Just(data).setFailureType(to: ErrorEnvelope.self).eraseToAnyPublisher()

      }.eraseToAnyPublisher()
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
  fileprivate func requestWithFileUpload(_ request: URLRequest, uploading file: URL,
                                         named name: String) -> URLRequest {
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

    return mutableRequest
  }

  // Returns a producer that will execute the given upload once for each invocation of start().
  fileprivate func rac_requestWithFileUpload(_ request: URLRequest, uploading file: URL, named name: String)
    -> SignalProducer<(Data, URLResponse), Error> {
    let finalRequest = self.requestWithFileUpload(request, uploading: file, named: name)

    return SignalProducer { observer, disposable in
      let task = self.dataTask(with: finalRequest) { data, response, error in
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

  fileprivate func combine_requestWithFileUpload(_ request: URLRequest, uploading file: URL,
                                                 named name: String) -> AnyPublisher<
    (data: Data, response: URLResponse),
                                                   URLError
                                                 > {
    let finalRequest = self.requestWithFileUpload(request, uploading: file, named: name)

    let subject = PassthroughSubject<(Data, URLResponse), Error>()

    return DataTaskPublisher(request: finalRequest, session: self).eraseToAnyPublisher()
  }
}
