import Foundation
import Argo
import Curry
import Runes

public struct Author {
  public private(set) var avatar: Avatar
  public private(set) var id: Int
  public private(set) var name: String
  public private(set) var urls: Url

  public struct Avatar {
    public private(set) var medium: String?
    public private(set) var small: String
    public private(set) var thumb: String
  }

  public struct Url {
    public private(set) var api: String
    public private(set) var web: String
  }
}

extension Author: Swift.Decodable {

  enum CodingKeys: String, CodingKey {
    case avatar
    case id
    case name
    case urls
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.avatar = try values.decode(Avatar.self, forKey: .avatar)
    self.id = try values.decode(Int.self, forKey: .id)
    self.name = try values.decode(String.self, forKey: .name)
    self.urls = try values.decode(Url.self, forKey: .urls)
  }
}

extension Author.Avatar: Swift.Decodable {

  enum CodingKeys: String, CodingKey {
    case medium
    case small
    case thumb
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.medium = try values.decode(String?.self, forKey: .medium)
    self.small = try values.decode(String.self, forKey: .small)
    self.thumb = try values.decode(String.self, forKey: .thumb)
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
