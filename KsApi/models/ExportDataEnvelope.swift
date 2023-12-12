

public struct ExportDataEnvelope {
  public let expiresAt: String?
  public var state: State
  public let dataUrl: String?

  public enum State: String, Decodable, Equatable {
    case none
    case created
    case queued
    case assembling
    case assembled
    case uploading
    case completed
    case failed
    case expired
    case unknown // Default value if server response can't be parsed.

    // Throws error if the value isn't a valid string. If the value is a valid string, it maps to
    // its corresponding enum case, if it exists, and to `unknown` otherwise.
    public init(from decoder: Decoder) throws {
      let rawSelf = try decoder.singleValueContainer().decode(String.self)
      self = .init(rawValue: rawSelf) ?? .unknown
    }
  }
}

extension ExportDataEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case expiresAt = "expires_at"
    case state
    case dataUrl = "data_url"
  }
}
