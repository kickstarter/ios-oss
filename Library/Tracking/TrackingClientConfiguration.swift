import Foundation
import KsApi

public enum TrackingClientIdentifier: String {
  case dataLake = "DataLake"

  var emoji: String {
    switch self {
    case .dataLake: return "💧"
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
  public static let dataLake: TrackingClientConfiguration = .init(
    envelope: { records in ["records": records] },
    httpMethod: .PUT,
    identifier: .dataLake,
    recordDictionary: dataLakeRecordDictionary,
    request: dataLakeRequest,
    url: dataLakeUrl
  )
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
