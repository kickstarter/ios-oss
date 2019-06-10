import Argo
import Curry
import Foundation
import Runes

public struct Author: Swift.Decodable {
  public var avatar: Avatar
  public var id: Int
  public var name: String
  public var urls: Url

  public struct Avatar: Swift.Decodable {
    public var medium: String?
    public var small: String
    public var thumb: String
  }

  public struct Url {
    public var api: String
    public var web: String
  }
}

extension Author.Url: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case api
    case user
    case web
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.api = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .api)
      .decode(String.self, forKey: .user)
    self.web = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .web)
      .decode(String.self, forKey: .user)
  }
}

extension Author: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Author> {
    return curry(Author.init)
      <^> json <| "avatar"
      <*> json <| "id"
      <*> json <| "name"
      <*> json <| "urls"
  }
}

extension Author.Avatar: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Author.Avatar> {
    return curry(Author.Avatar.init)
      <^> json <|? "medium"
      <*> json <| "small"
      <*> json <| "thumb"
  }
}

extension Author.Url: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Author.Url> {
    return curry(Author.Url.init)
      <^> json <| ["api", "user"]
      <*> json <| ["web", "user"]
  }
}
