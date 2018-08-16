import Argo
import Curry
import Runes

public struct ExportDataEnvelope {
  public let expiresAt: String?
  public let state: State
  public let dataUrl: String?

  public enum State: String {
    case queued
    case processing
    case completed
    case expired
  }
}

extension ExportDataEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ExportDataEnvelope> {
    return curry(ExportDataEnvelope.init)
    <^> json <|? "expires_at"
    <*> json <| "state"
    <*> json <|? "data_url"
  }
}

extension ExportDataEnvelope.State: Argo.Decodable {

}
