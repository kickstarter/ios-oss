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
  var helpCenterUrl: URL { get }
  var environmentName: String { get }
}

public func == (lhs: ServerConfigType, rhs: ServerConfigType) -> Bool {
  return
    type(of: lhs) == type(of: rhs) &&
    lhs.apiBaseUrl == rhs.apiBaseUrl &&
    lhs.webBaseUrl == rhs.webBaseUrl &&
    lhs.apiClientAuth == rhs.apiClientAuth &&
    lhs.basicHTTPAuth == rhs.basicHTTPAuth &&
    lhs.graphQLEndpointUrl == rhs.graphQLEndpointUrl &&
    lhs.helpCenterUrl == rhs.helpCenterUrl
}

private let gqlPath = "graph"

public struct ServerConfig: ServerConfigType {

  public fileprivate(set) var apiBaseUrl: URL
  public fileprivate(set) var webBaseUrl: URL
  public fileprivate(set) var apiClientAuth: ClientAuthType
  public fileprivate(set) var basicHTTPAuth: BasicHTTPAuthType?
  public fileprivate(set) var graphQLEndpointUrl: URL
  public fileprivate(set) var helpCenterUrl: URL
  public fileprivate(set) var environmentName: String

  public static let production: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.production)")!,
    webBaseUrl: URL(string: "https://\(Secrets.WebEndpoint.production)")!,
    apiClientAuth: ClientAuth.production,
    basicHTTPAuth: nil,
    graphQLEndpointUrl: URL(string: "https://\(Secrets.WebEndpoint.production)")!
      .appendingPathComponent(gqlPath),
    helpCenterUrl: URL(string: Secrets.HelpCenter.endpoint)!,
    environmentName: "Production"
  )

  public static let staging: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.staging)")!,
    webBaseUrl: URL(string: "https://\(Secrets.WebEndpoint.staging)")!,
    apiClientAuth: ClientAuth.development,
    basicHTTPAuth: BasicHTTPAuth.development,
    graphQLEndpointUrl: URL(string: "https://\(Secrets.WebEndpoint.staging)")!
      .appendingPathComponent(gqlPath),
    helpCenterUrl: URL(string: Secrets.HelpCenter.endpoint)!,
    environmentName: "Staging"
  )

  public static let local: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "http://api.ksr.test")!,
    webBaseUrl: URL(string: "http://ksr.test")!,
    apiClientAuth: ClientAuth.development,
    basicHTTPAuth: BasicHTTPAuth.development,
    graphQLEndpointUrl: URL(string: "http://ksr.dev")!.appendingPathComponent(gqlPath),
    helpCenterUrl: URL(string: Secrets.HelpCenter.endpoint)!,
    environmentName: "Local"
  )

  public init(apiBaseUrl: URL,
              webBaseUrl: URL,
              apiClientAuth: ClientAuthType,
              basicHTTPAuth: BasicHTTPAuthType?,
              graphQLEndpointUrl: URL,
              helpCenterUrl: URL,
              environmentName: String = "") {

    self.apiBaseUrl = apiBaseUrl
    self.webBaseUrl = webBaseUrl
    self.apiClientAuth = apiClientAuth
    self.basicHTTPAuth = basicHTTPAuth
    self.graphQLEndpointUrl = graphQLEndpointUrl
    self.helpCenterUrl = helpCenterUrl
    self.environmentName = environmentName
  }
}
