import Foundation
import KsApi

public enum TrackingClientIdentifier: String {
  case dataLake = "DataLake"
  case koala = "Koala"

  var emoji: String {
    switch self {
    case .dataLake: return "💧"
    case .koala: return "🐨"
    }
  }
}

public struct TrackingClientConfiguration {
  public let envelope: (Any) -> Any
  public let httpMethod: KsApi.Method
  public let identifier: TrackingClientIdentifier
  public let recordDictionary: (String, [String: Any]) -> [String: Any]
  public let request: (TrackingClientConfiguration, EnvironmentType, Data) -> URLRequest?
  public let url: (EnvironmentType) -> URL?
}

extension TrackingClientConfiguration {
  public static let koala: TrackingClientConfiguration = .init(
    envelope: { $0 },
    httpMethod: .GET,
    identifier: .koala,
    recordDictionary: { event, properties in ["event": event, "properties": properties] },
    request: { config, environmentType, data in
      guard
        let baseUrl = config.url(environmentType),
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
      else { return nil }

      let dataString = data.base64EncodedString(options: [])

      if dataString.count >= 10_000 {
        // swiftlint:disable:next line_length
        print("\(config.identifier.emoji) [\(config.identifier) Error]: Base64 payload is longer than 10,000 characters.")
      }

      components.queryItems = [
        URLQueryItem(name: "data", value: dataString)
      ]
      .compactMap { $0 }

      guard let url = components.url else { return nil }

      var request = URLRequest(url: url)
      request.httpMethod = config.httpMethod.rawValue

      return request
    },
    url: { environmentType in
      let urlString: String

      switch environmentType {
      case .production:
        urlString = Secrets.KoalaEndpoint.production
      default:
        urlString = Secrets.KoalaEndpoint.staging
      }

      return URL(string: urlString)
    }
  )

  public static let dataLake: TrackingClientConfiguration = .init(
    envelope: { records in ["records": records] },
    httpMethod: .PUT,
    identifier: .dataLake,
    recordDictionary: { event, properties in
      [
        "data": [
          "event": event,
          "properties": properties
        ],
        "partition-key": UUID().uuidString
      ]
    },
    request: { config, environmentType, data in
      guard let baseUrl = config.url(environmentType) else { return nil }

      var request = URLRequest(url: baseUrl)
      request.httpMethod = config.httpMethod.rawValue
      request.httpBody = data

      let currentHeaders = request.allHTTPHeaderFields ?? [:]
      request.allHTTPHeaderFields = currentHeaders.withAllValuesFrom(
        ["Content-Type": "application/json; charset=utf-8"]
      )

      return request
    },
    url: { environmentType in
      let urlString: String

      switch environmentType {
      case .production:
        urlString = Secrets.LakeEndpoint.production
      default:
        urlString = Secrets.LakeEndpoint.staging
      }

      return URL(string: urlString)
    }
  )
}
