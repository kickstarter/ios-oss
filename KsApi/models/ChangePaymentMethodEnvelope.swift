import Curry
import Runes

public struct ChangePaymentMethodEnvelope {
  public let newCheckoutUrl: String?
  public let status: Int
}

/*
 public init(from decoder: Decoder) throws {
   let values = try decoder.container(keyedBy: CodingKeys.self)
   do {
     let moreComments = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .api)
       .decode(String.self, forKey: .moreComments)
     self.api = CommentsEnvelope.UrlsEnvelope.ApiEnvelope(moreComments: moreComments)
   } catch {
     self.api = CommentsEnvelope.UrlsEnvelope.ApiEnvelope(moreComments: "")
   }
 }
 */
extension ChangePaymentMethodEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ChangePaymentMethodEnvelope> {
    //TODO - fix mapping
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
