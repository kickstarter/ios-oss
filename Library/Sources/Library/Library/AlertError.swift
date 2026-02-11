import Foundation
import KsApi

public enum AlertError {
  case genericError(message: String)
  case facebookTokenFail
  case facebookLoginAttemptFail(error: NSError)
  case genericFacebookError(envelope: ErrorEnvelope)
  case facebookConnectAccountTaken(envelope: ErrorEnvelope)
  case facebookConnectEmailTaken(envelope: ErrorEnvelope)

  var code: Int {
    switch self {
    case .genericError:
      0
    case .facebookTokenFail:
      1
    case .facebookLoginAttemptFail:
      2
    case .genericFacebookError:
      3
    case .facebookConnectAccountTaken:
      4
    case .facebookConnectEmailTaken:
      5
    }
  }

  // Crashlytics prefers NSErrors
  public var nsError: NSError {
    return NSError(
      domain: "Facebook.AlertError",
      code: self.code,
      userInfo: [
        NSLocalizedDescriptionKey: "Facebook login failure"
      ]
    )
  }
}
