import Curry
import Runes

public struct ExportDataEnvelope {
  public let expiresAt: String?
  public let state: State
  public let dataUrl: String?

  public enum State: String, Swift.Decodable {
    case queued
    case processing
    case completed
    case expired
  }
}

extension ExportDataEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case expiresAt = "expires_at"
    case state = "state"
    case dataUrl = "data_url"
  }
}
/*
extension ExportDataEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ExportDataEnvelope> {
    return curry(ExportDataEnvelope.init)
      <^> json <|? "expires_at"
      <*> json <| "state"
      <*> json <|? "data_url"
  }
}

extension ExportDataEnvelope.State: Decodable {}
*/
