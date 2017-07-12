import Argo
import Curry
import Runes

public struct CheckoutEnvelope {
  public enum State: String {
    case authorizing
    case failed
    case successful
    case verifying
  }
  public let state: State
  public let stateReason: String
}

extension CheckoutEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<CheckoutEnvelope> {
    let create = curry(CheckoutEnvelope.init)
    return create
      <^> json <| "state"
      <*> (json <| "state_reason" <|> .success(""))
  }
}

extension CheckoutEnvelope.State: Argo.Decodable {
}
