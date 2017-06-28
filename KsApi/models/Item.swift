import Argo
import Curry
import Runes

public struct Item {
  public let description: String?
  public let id: Int
  public let name: String
  public let projectId: Int
}

extension Item: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Item> {
    let create = curry(Item.init)
    return create
      <^> json <|? "description"
      <*> json <| "id"
      <*> json <| "name"
      <*> json <| "project_id"
  }
}
