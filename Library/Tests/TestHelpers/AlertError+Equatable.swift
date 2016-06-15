@testable import Library

extension AlertError: Equatable {}

public func == (lhs: AlertError, rhs: AlertError) -> Bool {
  switch (lhs, rhs) {
  case (.genericError, .genericError),
       (.facebookTokenFail, .facebookTokenFail),
       (.facebookLoginAttemptFail, .facebookLoginAttemptFail),
       (.genericFacebookError, .genericFacebookError),
       (.facebookConnectAccountTaken, .facebookConnectAccountTaken),
       (.facebookConnectEmailTaken, .facebookConnectEmailTaken):
    return true
  default: return false
  }
}
