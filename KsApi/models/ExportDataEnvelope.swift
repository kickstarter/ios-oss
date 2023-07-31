

public struct ExportDataEnvelope {
  public let expiresAt: String?
  public let dataUrl: String?
  public var state: State {
    guard let rawState, let state = State(rawValue: rawState) else {
      return .unknown
    }
    return state
  }

  private let rawState: String?

  public init(expiresAt: String?, state: State, dataUrl: String?) {
    self.expiresAt = expiresAt
    self.dataUrl = dataUrl
    self.rawState = state.rawValue
  }

  public init(expiresAt: String?, rawState: String?, dataUrl: String?) {
    self.expiresAt = expiresAt
    self.dataUrl = dataUrl
    self.rawState = rawState
  }

  public enum State: String, Decodable {
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
  }
}

extension ExportDataEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case expiresAt = "expires_at"
    case rawState = "state"
    case dataUrl = "data_url"
  }
}
