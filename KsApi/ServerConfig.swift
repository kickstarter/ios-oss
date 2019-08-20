// swiftlint:disable force_unwrapping
import Foundation

/**
 A type that knows the location of a Kickstarter API and web server.
 */
public protocol ServerConfigType {
  var apiBaseUrl: URL { get }
  var webBaseUrl: URL { get }
  var apiClientAuth: ClientAuthType { get }
  var basicHTTPAuth: BasicHTTPAuthType? { get }
  var graphQLEndpointUrl: URL { get }
  var environment: EnvironmentType { get }
}

public func == (lhs: ServerConfigType, rhs: ServerConfigType) -> Bool {
  return
    type(of: lhs) == type(of: rhs) &&
    lhs.apiBaseUrl == rhs.apiBaseUrl &&
    lhs.webBaseUrl == rhs.webBaseUrl &&
    lhs.apiClientAuth == rhs.apiClientAuth &&
    lhs.basicHTTPAuth == rhs.basicHTTPAuth &&
    lhs.graphQLEndpointUrl == rhs.graphQLEndpointUrl &&
    lhs.environment == rhs.environment
}

public enum EnvironmentType: String, CaseIterable {
  case production = "Production"
  case staging = "Staging"
  case development = "Development"
  case local = "Local"
}

private let gqlPath = "graph"

public struct ServerConfig: ServerConfigType {
  public var apiBaseUrl: URL
  public var webBaseUrl: URL
  public var apiClientAuth: ClientAuthType
  public var basicHTTPAuth: BasicHTTPAuthType?
  public var graphQLEndpointUrl: URL
  public var environment: EnvironmentType

  public static let production: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.production)")!,
    webBaseUrl: URL(string: "https://\(Secrets.WebEndpoint.production)")!,
    apiClientAuth: ClientAuth.production,
    basicHTTPAuth: nil,
    graphQLEndpointUrl: URL(string: "https://\(Secrets.WebEndpoint.production)")!
      .appendingPathComponent(gqlPath),
    environment: EnvironmentType.production
  )

  public static let staging: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.staging)")!,
    webBaseUrl: URL(string: "https://\(Secrets.WebEndpoint.staging)")!,
    apiClientAuth: ClientAuth.development,
    basicHTTPAuth: BasicHTTPAuth.development,
    graphQLEndpointUrl: URL(string: "https://\(Secrets.WebEndpoint.staging)")!
      .appendingPathComponent(gqlPath),
    environment: EnvironmentType.staging
  )

  public static let development: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.development)")!,
    webBaseUrl: URL(string: "https://\(Secrets.WebEndpoint.development)")!,
    apiClientAuth: ClientAuth.development,
    basicHTTPAuth: BasicHTTPAuth.development,
    graphQLEndpointUrl: URL(string: "https://\(Secrets.WebEndpoint.development)")!
      .appendingPathComponent(gqlPath),
    environment: EnvironmentType.development
  )

  public static let local: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "http://api.ksr.test")!,
    webBaseUrl: URL(string: "http://ksr.test")!,
    apiClientAuth: ClientAuth.development,
    basicHTTPAuth: BasicHTTPAuth.development,
    graphQLEndpointUrl: URL(string: "http://ksr.test")!.appendingPathComponent(gqlPath),
    environment: EnvironmentType.local
  )

  public init(
    apiBaseUrl: URL,
    webBaseUrl: URL,
    apiClientAuth: ClientAuthType,
    basicHTTPAuth: BasicHTTPAuthType?,
    graphQLEndpointUrl: URL,
    environment: EnvironmentType = .production
  ) {
    self.apiBaseUrl = apiBaseUrl
    self.webBaseUrl = webBaseUrl
    self.apiClientAuth = apiClientAuth
    self.basicHTTPAuth = basicHTTPAuth
    self.graphQLEndpointUrl = graphQLEndpointUrl
    self.environment = environment
  }

  public static func config(for environment: EnvironmentType) -> ServerConfigType {
    switch environment {
    case .local:
      return ServerConfig.local
    case .development:
      return ServerConfig.development
    case .staging:
      return ServerConfig.staging
    case .production:
      return ServerConfig.production
    }
  }
}
