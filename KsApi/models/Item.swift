import Curry
import Runes

public struct Item {
  public let description: String?
  public let id: Int
  public let name: String
  public let projectId: Int
}

extension Item: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case description
    case id
    case name
    case projectId = "project_id"
  }
}

/*
 extension Item: Decodable {
 public static func decode(_ json: JSON) -> Decoded<Item> {
   return curry(Item.init)
     <^> json <|? "description"
     <*> json <| "id"
     <*> json <| "name"
     <*> json <| "project_id"
 }
 }
 */
