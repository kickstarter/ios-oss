import Argo
import Curry
import Runes

public struct UpdatePledgeEnvelope {
  public let newCheckoutUrl: String?
  public let status: Int
}

extension UpdatePledgeEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<UpdatePledgeEnvelope> {
    return curry(UpdatePledgeEnvelope.init)
      <^> json <|? ["data", "new_checkout_url"]
      <*> ((json <| "status" >>- stringToIntOrZero) <|> (json <| "status"))
  }
}

private func stringToIntOrZero(_ string: String) -> Decoded<Int> {
  return
    Double(string).flatMap(Int.init).map(Decoded.success)
      ?? Int(string).map(Decoded.success)
      ?? .success(0)
}
