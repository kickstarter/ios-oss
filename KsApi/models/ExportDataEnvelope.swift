import Argo
import Curry
import Runes

public struct ExportDataEnvelope {
  public let expiresAt: String
  public let state: State

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
    <^> json <| "expires_at"
    <*> json <| "state"
  }
}

extension ExportDataEnvelope.State: Argo.Decodable {

}
