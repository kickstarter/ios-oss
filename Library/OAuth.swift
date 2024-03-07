import AuthenticationServices
import Combine
import FirebaseCrashlytics
import Foundation
import KsApi

public enum OAuthAuthorizationResult {
  case loggedIn
  case failure(errorMessage: String)
  case cancelled
}

public struct OAuth {
  public init() {}

  private static var cancellables = Set<AnyCancellable>()

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

  public static func createAuthorizationSession(onComplete: @escaping (OAuthAuthorizationResult) -> Void)
    -> ASWebAuthenticationSession? {
    do {
      let verifier = try PKCE.createCodeVerifier(byteLength: 32)
      if !PKCE.checkCodeVerifier(verifier) {
        return nil
      }

      let challenge = try PKCE.createCodeChallenge(fromVerifier: verifier)

      guard let url = authorizationURL(withCodeChallenge: challenge) else {
        return nil
      }

      let session = ASWebAuthenticationSession(
        url: url,
        callbackURLScheme: OAuth.redirectScheme
      ) { url, error in
        handleRedirect(redirectURL: url, error: error, verifier: verifier, onComplete: onComplete)
      }

      return session

    } catch {
      Crashlytics.crashlytics().record(error: error)
      return nil
    }
  }

  internal static func handleRedirect(
    redirectURL url: URL?,
    error: Error?,
    verifier: String,
    onComplete: @escaping (OAuthAuthorizationResult) -> Void
  ) {
    guard error == nil else {
      if let authenticationError = error as? ASWebAuthenticationSessionError,
        authenticationError.code == .canceledLogin {
        DispatchQueue.main.async {
          onComplete(.cancelled)
        }
      } else {
        DispatchQueue.main.async {
          onComplete(.failure(errorMessage: Strings.Something_went_wrong_please_try_again()))
        }
      }

      return
    }

    guard let code = codeFromRedirectURL(url) else {
      DispatchQueue.main.async {
        onComplete(.failure(errorMessage: Strings.Something_went_wrong_please_try_again()))
      }
      return
    }

    let params = OAuthTokenExchangeParams(temporaryToken: code, codeVerifier: verifier)

    AppEnvironment.current.apiService.exchangeTokenForOAuthToken(params: params)
      .flatMap { response in
        let token = response.token
        // TODO: This would be neater if we can just return the V1 user from the exchange endpoint.

        // Return a publisher that emits a tuple of (token, user) when the user request completes
        return Just(token).setFailureType(to: ErrorEnvelope.self)
          .zip(AppEnvironment.current.apiService.fetchUserSelf_combine(withOAuthToken: token))
      }
      .receive(on: RunLoop.main)
      .sink { result in
        if case let .failure(error) = result {
          let message = error.errorMessages.first ?? Strings.login_errors_unable_to_log_in()
          onComplete(.failure(errorMessage: message))
        }
      } receiveValue: { token, user in
        let accessEnvelope = AccessTokenEnvelope(accessToken: token, user: user)
        AppEnvironment.login(accessEnvelope)

        // This is an imperfect bit of logging, since it doesn't differentiate between logins and signups.
        // But it makes up for the fact that we can't track any of this through the embedded web views.
        AppEnvironment.current.ksrAnalytics.trackLoginSubmitButtonClicked()

        onComplete(.loggedIn)

      }.store(in: &self.cancellables)
  }

  private static func codeFromRedirectURL(_ url: URL?) -> String? {
    guard let redirectURL = url else {
      return nil
    }

    let components = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false)
    return components?.queryItems?.first(where: { $0.name == "code" })?.value
  }
}
