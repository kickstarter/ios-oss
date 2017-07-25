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
}

public func == (lhs: ServerConfigType, rhs: ServerConfigType) -> Bool {
  return
    type(of: lhs) == type(of: rhs) &&
    lhs.apiBaseUrl == rhs.apiBaseUrl &&
    lhs.webBaseUrl == rhs.webBaseUrl &&
    lhs.apiClientAuth == rhs.apiClientAuth &&
    lhs.basicHTTPAuth == rhs.basicHTTPAuth
}

public struct ServerConfig: ServerConfigType {
  public let apiBaseUrl: URL
  public let webBaseUrl: URL
  public let apiClientAuth: ClientAuthType
  public let basicHTTPAuth: BasicHTTPAuthType?

  public static let production: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.production)")!,
    webBaseUrl: URL(string: "https://\(Secrets.WebEndpoint.production)")!,
    apiClientAuth: ClientAuth.production,
    basicHTTPAuth: nil
  )

  public static let staging: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.staging)")!,
    webBaseUrl: URL(string: "https://\(Secrets.WebEndpoint.staging)")!,
    apiClientAuth: ClientAuth.development,
    basicHTTPAuth: BasicHTTPAuth.development
  )

  public static let local: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "http://api.ksr.dev")!,
    webBaseUrl: URL(string: "http://ksr.dev")!,
    apiClientAuth: ClientAuth.development,
    basicHTTPAuth: BasicHTTPAuth.development
  )

  public init(apiBaseUrl: URL,
              webBaseUrl: URL,
              apiClientAuth: ClientAuthType,
              basicHTTPAuth: BasicHTTPAuthType?) {

    self.apiBaseUrl = apiBaseUrl
    self.webBaseUrl = webBaseUrl
    self.apiClientAuth = apiClientAuth
    self.basicHTTPAuth = basicHTTPAuth
  }
}
