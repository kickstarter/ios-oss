

public struct ExportDataEnvelope {
  public let expiresAt: String?
  public var state: State {
    if let stateString, let state = State(rawValue: stateString) {
      return state
    }
    return .unknown
  }

  public let dataUrl: String?
  private let stateString: String?

  public init(expiresAt: String?, state: State, dataUrl: String?) {
    self.expiresAt = expiresAt
    self.dataUrl = dataUrl
    self.stateString = state.rawValue
  }

  public init(expiresAt: String?, stateString: String?, dataUrl: String?) {
    self.expiresAt = expiresAt
    self.dataUrl = dataUrl
    self.stateString = stateString
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
    case stateString = "state"
    case dataUrl = "data_url"
  }
}
