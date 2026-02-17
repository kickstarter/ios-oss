import AuthenticationServices
import Foundation

private extension ASAuthorizationError {
  var nsError: NSError? {
    let reason: String
    switch self.code {
    case .canceled:
      reason = "Canceled"
    case .invalidResponse:
      reason = "Invalid response"
    case .notHandled:
      reason = "Not handled"
    case .failed:
      reason = "Failed"
    case .notInteractive:
      reason = "Not interactive"
    case .matchedExcludedCredential:
      reason = "Matched excluded credential"
    case .credentialImport:
      reason = "Credential import"
    case .credentialExport:
      reason = "Credential export"
    case .preferSignInWithApple:
      reason = "Prefer sign in with Apple"
    case .deviceNotConfiguredForPasskeyCreation:
      reason = "Device not configured for Passkey creation"
    case .unknown:
      fallthrough
    @unknown default:
      reason = "Unknown"
    }

    return NSError(
      domain: "ASAuthorizationError",
      code: self.errorCode,
      userInfo: [
        NSLocalizedDescriptionKey: "Unable to sign in with Apple. Reason: \(reason)"
      ]
    )
  }
}

public enum AppleAuthServicesError {
  case canceled
  case other(Error)

  private static let unknownError = NSError(
    domain: "AppleAuthServicesError",
    code: 0,
    userInfo: [
      NSLocalizedDescriptionKey: "Unable to sign in with Apple. Unknown error type."
    ]
  )

  /// Crashlytics prefers an `NSError`.
  var nsError: NSError? {
    switch self {
    case .canceled:
      return nil
    case let .other(error):
      if let asAuthError = error as? ASAuthorizationError {
        return asAuthError.nsError
      } else {
        return AppleAuthServicesError.unknownError
      }
    }
  }
}
