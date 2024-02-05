import Foundation

public struct OAuth {
  public init() {}

  public static let redirectScheme = "ksrauth2"
  public static func authorizationURL() -> URL {
    let base = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    // TODO: MBL-1159: This will take URL parameters, as defined in the ticket, for PKCE
    return base
  }
}
