import AuthenticationServices
import KsApi

struct OAuthError {
  private enum Code: Int {
    case missingCode = 1
    case exchangeFailed = 2
    case redirectError = 3
    case pkceError = 4
  }

  private let code: OAuthError.Code
  private let message: String

  private init(code: OAuthError.Code, message: String) {
    self.code = code
    self.message = message
  }

  var nsError: NSError {
    NSError(
      domain: "Library.OAuth",
      code: self.code.rawValue,
      userInfo: [
        NSLocalizedDescriptionKey: self.message
      ]
    )
  }

  static let missingCodeError = OAuthError(
    code: .missingCode,
    message: "Missing code in redirect URL"
  )

  static func exchangeFailedError(_ error: ErrorEnvelope?) -> OAuthError {
    guard let httpCode = error?.httpCode else {
      return OAuthError(
        code: .exchangeFailed,
        message: "Exchange API call failed"
      )
    }

    return OAuthError(
      code: .exchangeFailed,
      message: "Exchange API call failed with HTTP code \(httpCode)"
    )
  }

  static func redirectError(_ error: Error?) -> OAuthError {
    guard let authenticationError = error as? ASWebAuthenticationSessionError else {
      return OAuthError(
        code: .redirectError,
        message: "Redirect failed (with no underlying error)"
      )
    }

    return OAuthError(
      code: .redirectError,
      message: "Redirect failed with underlying error: \(authenticationError.code.rawValue)"
    )
  }

  static let pkceError = OAuthError(
    code: .pkceError,
    message: "Error in PKCE verification"
  )
}
