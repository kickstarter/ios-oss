import Curry
import Runes

public struct ErrorEnvelope {
  public let errorMessages: [String]
  public let ksrCode: KsrCode?
  public let httpCode: Int
  public let exception: Exception?
  public let facebookUser: FacebookUser?
  public let graphError: GraphError?
  private let data: AltErrorMessage?

  public init(
    errorMessages: [String],
    ksrCode: KsrCode?,
    httpCode: Int,
    exception: Exception?,
    facebookUser: FacebookUser? = nil,
    graphError: GraphError? = nil
  ) {
    self.errorMessages = errorMessages
    self.ksrCode = ksrCode
    self.httpCode = httpCode
    self.exception = exception
    self.facebookUser = facebookUser
    self.graphError = graphError
    self.data = nil
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

  public struct AltErrorMessage {
    public let errors: AltErrorDetails

    public struct AltErrorDetails {
      public let details: [String]
    }
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
    facebookUser: nil,
    graphError: nil
  )

  /**
   A general error that the error envelope JSON could not be parsed.
   */
  internal static let couldNotParseErrorEnvelopeJSON = ErrorEnvelope(
    errorMessages: [],
    ksrCode: .ErrorEnvelopeJSONParsingFailed,
    httpCode: 400,
    exception: nil,
    facebookUser: nil,
    graphError: nil
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
      facebookUser: nil,
      graphError: nil
    )
  }

  /**
   A general error that some JSON could not be decoded.

   - parameter decodeError: The JSONDecoder decoding error.

   - returns: An error envelope that describes why decoding failed.
   */
  internal static func couldNotDecodeJSON(_ decodeError: Error) -> ErrorEnvelope {
    return ErrorEnvelope(
      errorMessages: ["JSONDecoder decoding error: \(decodeError.localizedDescription)"],
      ksrCode: .DecodingJSONFailed,
      httpCode: 400,
      exception: nil,
      facebookUser: nil,
      graphError: nil
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
    facebookUser: nil,
    graphError: nil
  )
}

extension ErrorEnvelope: Error {}

extension ErrorEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case errorMessages = "error_messages"
    case ksrCode = "ksr_code"
    case httpCode = "http_code"
    case status
    case data
    case exception
    case facebookUser = "facebook_user"
  }

  public init(from decoder: Decoder) throws {
    // sometimes we make requests to the www server and JSON errors come back in a different envelope
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if values.contains(.httpCode) {
      self.errorMessages = try values.decode([String].self, forKey: .errorMessages)
      self.ksrCode = try values.decodeIfPresent(KsrCode.self, forKey: .ksrCode)
      self.httpCode = try values.decode(Int.self, forKey: .httpCode)
      self.exception = try values.decode(Exception.self, forKey: .exception)
      self.facebookUser = try values.decodeIfPresent(FacebookUser.self, forKey: .facebookUser)
      self.graphError = nil
      self.data = nil
    } else {
      self.data = try values.decodeIfPresent(ErrorEnvelope.AltErrorMessage.self, forKey: .data)
      self.errorMessages = self.data?.errors.details ?? []
      self.ksrCode = ErrorEnvelope.KsrCode.UnknownCode
      self.httpCode = try values.decode(Int.self, forKey: .status)
      self.exception = nil
      self.facebookUser = nil
      self.graphError = nil
    }
  }
}

/*
 extension ErrorEnvelope: Decodable {
 public static func decode(_ json: JSON) -> Decoded<ErrorEnvelope> {
   // Typically API errors come back in this form...
   let standardErrorEnvelope = curry(ErrorEnvelope.init)
     <^> json <|| "error_messages"
     <*> json <|? "ksr_code"
     <*> json <| "http_code"
     <*> json <|? "exception"
     <*> json <|? "facebook_user"
     <*> .success(nil)

   // ...but sometimes we make requests to the www server and JSON errors come back in a different envelope
   let nonStandardErrorEnvelope = {
     curry(ErrorEnvelope.init)
       <^> concatSuccesses([
         json <|| ["data", "errors", "amount"],
         json <|| ["data", "errors", "backer_reward"]
       ])
       <*> .success(ErrorEnvelope.KsrCode.UnknownCode)
       <*> json <| "status"
       <*> .success(nil)
       <*> .success(nil)
       <*> .success(nil)
   }

   return standardErrorEnvelope <|> nonStandardErrorEnvelope()
 }
 }
 */
extension ErrorEnvelope.AltErrorMessage: Swift.Decodable {}

extension ErrorEnvelope.AltErrorMessage.AltErrorDetails: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case amount
    case backerReward = "backer_reward"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let value = try values.decodeIfPresent([String].self, forKey: .amount) {
      self.details = value
    } else {
      self.details = try values.decode([String].self, forKey: .backerReward)
    }
  }
}

extension ErrorEnvelope.Exception: Swift.Decodable {}

extension ErrorEnvelope.Exception: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ErrorEnvelope.Exception> {
    return curry(ErrorEnvelope.Exception.init)
      <^> json <||? "backtrace"
      <*> json <|? "message"
  }
}

extension ErrorEnvelope.KsrCode: Swift.Decodable {
  public init(from decoder: Decoder) throws {
    self = try ErrorEnvelope
      .KsrCode(rawValue: decoder.singleValueContainer().decode(String.self)) ?? ErrorEnvelope.KsrCode
      .UnknownCode
  }
}

extension ErrorEnvelope.KsrCode: Decodable {
  public static func decode(_ j: JSON) -> Decoded<ErrorEnvelope.KsrCode> {
    switch j {
    case let .string(s):
      return pure(ErrorEnvelope.KsrCode(rawValue: s) ?? ErrorEnvelope.KsrCode.UnknownCode)
    default:
      return .typeMismatch(expected: "ErrorEnvelope.KsrCode", actual: j)
    }
  }
}

extension ErrorEnvelope.FacebookUser: Swift.Decodable {}

extension ErrorEnvelope.FacebookUser: Decodable {
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
    .success((accum.value ?? []) + (decoded.value ?? []))
  }
}

// MARK: - GraphError

// FIXME: We should try to included error messages and/or httpCode
extension ErrorEnvelope {
  public static func envelope(from graphError: GraphError) -> ErrorEnvelope {
    return ErrorEnvelope(
      errorMessages: [],
      ksrCode: nil,
      httpCode: 0,
      exception: nil,
      graphError: graphError
    )
  }
}
