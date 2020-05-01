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

extension TrackingClientIdentifier: CustomStringConvertible {
  public var description: String {
    return self.rawValue
  }
}

public typealias TrackingClientRecordDictionary = (String, [String: Any]) -> [String: Any]
public typealias TrackingClientRequest = (TrackingClientConfiguration, EnvironmentType, Data) -> URLRequest?
public typealias TrackingClientURL = (EnvironmentType) -> URL?

public struct TrackingClientConfiguration {
  public let envelope: (Any) -> Any
  public let httpMethod: KsApi.Method
  public let identifier: TrackingClientIdentifier
  public let recordDictionary: TrackingClientRecordDictionary
  public let request: TrackingClientRequest
  public let url: TrackingClientURL
}

extension TrackingClientConfiguration {
  public static let koala: TrackingClientConfiguration = .init(
    envelope: { $0 },
    httpMethod: .POST,
    identifier: .koala,
    recordDictionary: koalaRecordDictionary,
    request: koalaRequest,
    url: koalaUrl
  )

  public static let dataLake: TrackingClientConfiguration = .init(
    envelope: { records in ["records": records] },
    httpMethod: .PUT,
    identifier: .dataLake,
    recordDictionary: dataLakeRecordDictionary,
    request: dataLakeRequest,
    url: dataLakeUrl
  )
}

// MARK: - Koala Functions

private let koalaRecordDictionary: TrackingClientRecordDictionary = { event, properties in
  ["event": event, "properties": properties]
}

private let koalaRequest: TrackingClientRequest = { config, environmentType, data in
  guard
    let baseUrl = config.url(environmentType),
    var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
  else { return nil }

  let dataString = data.base64EncodedString(options: [])

  if dataString.count >= 10_000 {
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
}

private let koalaUrl: TrackingClientURL = { environmentType in
  let urlString: String

  switch environmentType {
  case .production:
    urlString = Secrets.KoalaEndpoint.production
  default:
    urlString = Secrets.KoalaEndpoint.staging
  }

  return URL(string: urlString)
}

// MARK: - DataLake Functions

private let dataLakeRecordDictionary: TrackingClientRecordDictionary = { event, properties in
  [
    "data": [
      "event": event,
      "properties": properties
    ],
    "partition-key": partitionKey()
  ]
}

private let dataLakeRequest: TrackingClientRequest = { config, environmentType, data in
  guard let baseUrl = config.url(environmentType) else { return nil }

  var request = URLRequest(url: baseUrl)
  request.httpMethod = config.httpMethod.rawValue
  request.httpBody = data

  let currentHeaders = request.allHTTPHeaderFields ?? [:]
  request.allHTTPHeaderFields = currentHeaders.withAllValuesFrom(
    ["Content-Type": "application/json; charset=utf-8"]
  )

  return AppEnvironment.current.apiService.preparedRequest(forRequest: request)
}

private let dataLakeUrl: TrackingClientURL = { environmentType in
  let urlString: String

  switch environmentType {
  case .production:
    urlString = Secrets.LakeEndpoint.production
  default:
    urlString = Secrets.LakeEndpoint.staging
  }

  return URL(string: urlString)
}

private func partitionKey() -> String {
  return AppEnvironment.current.currentUser.flatMap { $0.id }.map(String.init)
    .coalesceWith(AppEnvironment.current.device.identifierForVendor?.uuidString)
    .coalesceWith(UUID().uuidString)
}
