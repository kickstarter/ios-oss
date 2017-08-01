import Argo
import Curry
import Runes

public struct ErrorEnvelope {
  public let errorMessages: [String]
  public let ksrCode: KsrCode?
  public let httpCode: Int
  public let exception: Exception?
  public let facebookUser: FacebookUser?

  public init(errorMessages: [String], ksrCode: KsrCode?, httpCode: Int, exception: Exception?,
              facebookUser: FacebookUser? = nil) {
    self.errorMessages = errorMessages
    self.ksrCode = ksrCode
    self.httpCode = httpCode
    self.exception = exception
    self.facebookUser = facebookUser
  }

  public enum KsrCode: String {
    // Codes defined by the server
    case AccessTokenInvalid = "access_token_invalid"
    case ConfirmFacebookSignup = "confirm_facebook_signup"
    case FacebookConnectAccountTaken = "facebook_connect_account_taken"
    case FacebookConnectEmailTaken = "facebook_connect_email_taken"
    case FacebookInvalidAccessToken = "facebook_invalid_access_token"
    case InvalidXauthLogin = "invalid_xauth_login"
    case MissingFacebookEmail = "missing_facebook_email"
    case TfaFailed = "tfa_failed"
    case TfaRequired = "tfa_required"

    // Catch all code for when server sends code we don't know about yet
    case UnknownCode = "__internal_unknown_code"

    // Codes defined by the client
    case JSONParsingFailed = "json_parsing_failed"
    case ErrorEnvelopeJSONParsingFailed = "error_json_parsing_failed"
    case DecodingJSONFailed = "decoding_json_failed"
    case InvalidPaginationUrl = "invalid_pagination_url"
  }

  public struct Exception {
    public let backtrace: [String]?
    public let message: String?
  }

  public struct FacebookUser {
    public let id: Int64
    public let name: String
    public let email: String
  }

  /**
   A general error that JSON could not be parsed.
  */
  internal static let couldNotParseJSON = ErrorEnvelope(
    errorMessages: [],
    ksrCode: .JSONParsingFailed,
    httpCode: 400,
    exception: nil,
    facebookUser: nil
  )

  /**
   A general error that the error envelope JSON could not be parsed.
  */
  internal static let couldNotParseErrorEnvelopeJSON = ErrorEnvelope(
    errorMessages: [],
    ksrCode: .ErrorEnvelopeJSONParsingFailed,
    httpCode: 400,
    exception: nil,
    facebookUser: nil
  )

  /**
   A general error that some JSON could not be decoded.

   - parameter decodeError: The Argo decoding error.

   - returns: An error envelope that describes why decoding failed.
   */
  internal static func couldNotDecodeJSON(_ decodeError: DecodeError) -> ErrorEnvelope {
    return ErrorEnvelope(
      errorMessages: ["Argo decoding error: \(decodeError.description)"],
      ksrCode: .DecodingJSONFailed,
      httpCode: 400,
      exception: nil,
      facebookUser: nil
    )
  }

  /**
   A error that the pagination URL is invalid.

   - parameter decodeError: The Argo decoding error.

   - returns: An error envelope that describes why decoding failed.
   */
  internal static let invalidPaginationUrl = ErrorEnvelope(
    errorMessages: [],
    ksrCode: .InvalidPaginationUrl,
    httpCode: 400,
    exception: nil,
    facebookUser: nil
  )
}

extension ErrorEnvelope: Error {}

extension ErrorEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ErrorEnvelope> {
    let create = curry(ErrorEnvelope.init)

    // Typically API errors come back in this form...
    let standardErrorEnvelope = create
      <^> json <|| "error_messages"
      <*> json <|? "ksr_code"
      <*> json <| "http_code"
      <*> json <|? "exception"
      <*> json <|? "facebook_user"

    // ...but sometimes we make requests to the www server and JSON errors come back in a different envelope
    let nonStandardErrorEnvelope = {
      create
        <^> concatSuccesses([
          json <|| ["data", "errors", "amount"],
          json <|| ["data", "errors", "backer_reward"],
          ])
        <*> .success(ErrorEnvelope.KsrCode.UnknownCode)
        <*> json <| "status"
        <*> .success(nil)
        <*> .success(nil)
    }

    return standardErrorEnvelope <|> nonStandardErrorEnvelope()
  }
}

extension ErrorEnvelope.Exception: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ErrorEnvelope.Exception> {
    return curry(ErrorEnvelope.Exception.init)
      <^> json <||? "backtrace"
      <*> json <|? "message"
  }
}

extension ErrorEnvelope.KsrCode: Argo.Decodable {
  public static func decode(_ j: JSON) -> Decoded<ErrorEnvelope.KsrCode> {
    switch j {
    case let .string(s):
      return pure(ErrorEnvelope.KsrCode(rawValue: s) ?? ErrorEnvelope.KsrCode.UnknownCode)
    default:
      return .typeMismatch(expected: "ErrorEnvelope.KsrCode", actual: j)
    }
  }
}

extension ErrorEnvelope.FacebookUser: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ErrorEnvelope.FacebookUser> {
    return curry(ErrorEnvelope.FacebookUser.init)
      <^> json <| "id"
      <*> json <| "name"
      <*> json <| "email"
  }
}

// Concats an array of decoded arrays into a decoded array. Ignores all failed decoded values, and so
// always returns a successfully decoded value.
private func concatSuccesses<A>(_ decodeds: [Decoded<[A]>]) -> Decoded<[A]> {

  return decodeds.reduce(Decoded.success([])) { accum, decoded in
    .success( (accum.value ?? []) + (decoded.value ?? []) )
  }
}
