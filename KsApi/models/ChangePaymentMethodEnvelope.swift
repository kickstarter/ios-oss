import Argo
import Curry
import Runes

public struct ChangePaymentMethodEnvelope {
  public let newCheckoutUrl: String?
  public let status: Int
}

extension ChangePaymentMethodEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ChangePaymentMethodEnvelope> {
    return curry(ChangePaymentMethodEnvelope.init)
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
