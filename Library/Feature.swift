import Foundation

public enum Feature: String {
  case qualtrics = "ios_qualtrics"
  case emailVerificationFlow = "ios_email_verification_flow"
  case emailVerificationSkip = "ios_email_verification_skip"
  case segment = "ios_segment"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .qualtrics: return "Qualtrics"
    case .emailVerificationFlow: return "Email Verification Flow"
    case .emailVerificationSkip: return "Email Verification Skip"
    case .segment: return "Segment"
    }
  }
}
