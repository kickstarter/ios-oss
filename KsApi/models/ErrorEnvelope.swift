

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
    case GraphQLError = "graphql_error"
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
    public let id: String
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

   - parameter decodeError: The JSONDecoder decoding error.

   - returns: An error envelope that describes why decoding failed.
   */
  internal static func couldNotDecodeJSON(_ decodeError: Error) -> ErrorEnvelope {
    return ErrorEnvelope(
      errorMessages: [decodeError.localizedDescription],
      ksrCode: .DecodingJSONFailed,
      httpCode: 400,
      exception: nil,
      facebookUser: nil,
      graphError: nil
    )
  }

  /**
   A error that the pagination URL is invalid.

   - parameter decodeError: The Decoding error.

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

  internal static func graphError(_ message: String) -> ErrorEnvelope {
    return ErrorEnvelope(
      errorMessages: [message],
      ksrCode: .GraphQLError,
      httpCode: 200,
      exception: nil
    )
  }
}

extension ErrorEnvelope: Error {}

extension ErrorEnvelope: Decodable {
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
      self.exception = try values.decodeIfPresent(Exception.self, forKey: .exception)
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

extension ErrorEnvelope.AltErrorMessage: Decodable {}

extension ErrorEnvelope.AltErrorMessage.AltErrorDetails: Decodable {
  enum CodingKeys: String, CodingKey {
    case amount
    case backerReward = "backer_reward"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.details = try values.decodeIfPresent([String].self, forKey: .amount) ?? values
      .decode([String].self, forKey: .backerReward)
  }
}

extension ErrorEnvelope.Exception: Decodable {}

extension ErrorEnvelope.KsrCode: Decodable {
  public init(from decoder: Decoder) throws {
    self = try ErrorEnvelope
      .KsrCode(rawValue: decoder.singleValueContainer().decode(String.self)) ?? ErrorEnvelope.KsrCode
      .UnknownCode
  }
}

extension ErrorEnvelope.FacebookUser: Decodable {}

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
