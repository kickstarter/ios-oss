import Argo
import Curry
import Runes

public struct Item {
  public private(set) var description: String?
  public private(set) var id: Int
  public private(set) var name: String
  public private(set) var projectId: Int
}

extension Item: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Item> {
    let create = curry(Item.init)
    return create
      <^> json <|? "description"
      <*> json <| "id"
      <*> json <| "name"
      <*> json <| "project_id"
  }
}
