import Curry
import Runes

public struct ChangePaymentMethodEnvelope {
  public let newCheckoutUrl: String?
  public let status: Int
}

extension ChangePaymentMethodEnvelope: Swift.Decodable{
  private enum CodingKeys: String, CodingKey {
    case data = "data"
    case status = "status"
  }
  
  enum NestedCodingKeys: String, CodingKey {
      case newCheckoutUrl = "new_checkout_url"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let nestedValues = try? values.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .data){
      self.newCheckoutUrl = try nestedValues.decodeIfPresent(String.self, forKey: .newCheckoutUrl)
    }else{
      self.newCheckoutUrl = nil
    }
    if let stringStatus = try? values.decode(String.self, forKey: .status){
      self.status = stringToIntOrZero(stringStatus)
    }else{
      self.status = try values.decode(Int.self, forKey: .status)
    }
  }
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
/*
extension ChangePaymentMethodEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ChangePaymentMethodEnvelope> {
    // TODO: - fix mapping
    return curry(ChangePaymentMethodEnvelope.init)
      <^> json <|? ["data", "new_checkout_url"]
      <*> ((json <| "status" >>- stringToIntOrZero) <|> (json <| "status"))
  }
}
*/
private func stringToIntOrZero(_ string: String) -> Decoded<Int> {
  return
    Double(string).flatMap(Int.init).map(Decoded.success)
      ?? Int(string).map(Decoded.success)
      ?? .success(0)
}

private func stringToIntOrZero(_ string: String) -> Int {
  return
    Double(string).flatMap(Int.init)
      ?? Int(string)
      ?? 0
}
