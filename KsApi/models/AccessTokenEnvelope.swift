import Argo
import Curry
import Runes

public struct AccessTokenEnvelope {
  public let accessToken: String
  public let user: User
}

extension AccessTokenEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<AccessTokenEnvelope> {
    return curry(AccessTokenEnvelope.init)
      <^> json <| "access_token"
      <*> json <| "user"
  }
}
