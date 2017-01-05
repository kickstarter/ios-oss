import OpenTok

public struct OpenTokSessionConfig: Equatable {
  public let sessionId: String
  public let apiKey: String
  public let token: String

  public init(apiKey: String, sessionId: String, token: String) {
    self.apiKey = apiKey
    self.sessionId = sessionId
    self.token = token
  }
}

public func == (lhs: OpenTokSessionConfig, rhs: OpenTokSessionConfig) -> Bool {
  return lhs.apiKey == rhs.apiKey &&
    lhs.sessionId == rhs.sessionId &&
    lhs.token == rhs.token
}

internal protocol OTStreamType {}
extension OTStream: OTStreamType {}
internal protocol OTErrorType {}
extension OTError: OTErrorType {}
