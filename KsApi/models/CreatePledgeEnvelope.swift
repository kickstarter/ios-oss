import Argo
import Curry
import Runes

public struct CreatePledgeEnvelope {
  public private(set) var checkoutUrl: String?
  public private(set) var newCheckoutUrl: String?
  public private(set) var status: Int
}

extension CreatePledgeEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<CreatePledgeEnvelope> {
    return curry(CreatePledgeEnvelope.init)
      <^> json <|? ["data", "checkout_url"]
      <*> json <|? ["data", "new_checkout_url"]
      <*> ((json <| "status" >>- stringToIntOrZero) <|> (json <| "status"))
  }
}

private func stringToIntOrZero(_ string: String) -> Decoded<Int> {
  return
    Double(string).flatMap(Int.init).map(Decoded.success)
      ?? Int(string).map(Decoded.success)
      ?? .success(0)
}
