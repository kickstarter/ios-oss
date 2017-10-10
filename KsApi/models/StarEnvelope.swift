import Argo
import Curry
import Runes

public struct StarEnvelope {
  public private(set) var user: User
  public private(set) var project: Project
}

extension StarEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<StarEnvelope> {
    return curry(StarEnvelope.init)
      <^> json <| "user"
      <*> json <| "project"
  }
}
