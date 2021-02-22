import Foundation

public enum Feature: String {
  case emailVerificationFlow = "ios_email_verification_flow"
  case emailVerificationSkip = "ios_email_verification_skip"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .emailVerificationFlow: return "Email Verification Flow"
    case .emailVerificationSkip: return "Email Verification Skip"
    }
  }
}
