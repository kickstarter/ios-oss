import KsApi

public enum AlertError {
  case genericError(message: String)
  case facebookTokenFail
  case facebookLoginAttemptFail(error: NSError)
  case genericFacebookError(envelope: ErrorEnvelope)
  case facebookConnectAccountTaken(envelope: ErrorEnvelope)
  case facebookConnectEmailTaken(envelope: ErrorEnvelope)
}
