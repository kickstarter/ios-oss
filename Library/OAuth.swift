import AuthenticationServices
import Foundation
import KsApi

public struct OAuth {
  public init() {}

  static let redirectScheme = "ksrauth2"

  static func authorizationURL(withCodeChallenge challenge: String) -> URL? {
    let serverConfig = AppEnvironment.current.apiService.serverConfig
    let baseURL = serverConfig.webBaseUrl

    let parameters = [
      URLQueryItem(name: "redirect_uri", value: redirectScheme),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: "email"),
      URLQueryItem(name: "client_id", value: serverConfig.apiClientAuth.clientId),
      URLQueryItem(name: "code_challenge_method", value: "S256"),
      URLQueryItem(name: "code_challenge", value: challenge)
    ]

    var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
    components?.path = "/oauth/authorizations/new"
    components?.queryItems = parameters

    return components?.url
  }

  public static func createAuthorizationSession() -> ASWebAuthenticationSession? {
    do {
      let verifier = try PKCE.createCodeVerifier(byteLength: 32)
      let challenge = try PKCE.createCodeChallenge(fromVerifier: verifier)
      guard let url = authorizationURL(withCodeChallenge: challenge) else {
        return nil
      }

      let session = ASWebAuthenticationSession(
        url: url,
        callbackURLScheme: OAuth.redirectScheme
      ) { _, _ in
        // TODO: MBL-1159: Exchange information in callback for credentials, then login.
      }

      return session

    } catch {
      // TODO: Is there a way we can log/monitor these errors?
      return nil
    }
  }
}
