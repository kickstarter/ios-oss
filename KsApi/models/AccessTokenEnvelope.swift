import Argo
import Curry
import Runes

public struct AccessTokenEnvelope {
  public private(set) var accessToken: String
  public private(set) var user: User
}

extension AccessTokenEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<AccessTokenEnvelope> {
    return curry(AccessTokenEnvelope.init)
      <^> json <| "access_token"
      <*> json <| "user"
  }
}
