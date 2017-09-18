import Argo
import Curry
import Runes

public struct SubmitApplePayEnvelope {
  public private(set) var thankYouUrl: String
  public private(set) var status: Int
}

extension SubmitApplePayEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<SubmitApplePayEnvelope> {
    return curry(SubmitApplePayEnvelope.init)
      <^> json <| ["data", "thankyou_url"]
      <*> ((json <| "status" >>- stringToIntOrZero) <|> (json <| "status"))
  }
}

private func stringToIntOrZero(_ string: String) -> Decoded<Int> {
  return
    Double(string).flatMap(Int.init).map(Decoded.success)
      ?? Int(string).map(Decoded.success)
      ?? .success(0)
}
