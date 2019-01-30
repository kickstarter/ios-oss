import Argo
import Curry
import Runes

public struct Comment {
  public let author: Author
  public let body: String
  public let createdAt: TimeInterval
  public let deletedAt: TimeInterval?
  public let id: Int
}

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

extension Comment: Swift.Decodable {

  enum CodingKeys: String, CodingKey {
    case author
    case body
    case createdAt = "created_at"
    case deletedAt = "deleted_at"
    case id
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.author = try values.decode(Author.self, forKey: .author)
    self.body = try values.decode(String.self, forKey: .body)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    self.deletedAt = try values.decode(TimeInterval?.self, forKey: .deletedAt)
    self.id = try values.decode(Int.self, forKey: .id)
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

extension Author.Url: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Author.Url> {
    return curry(Author.Url.init)
      <^> json <| ["api"
      <*> json <| "web"
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

extension Author: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Author> {
    return curry(Author.init)
      <^> json <| "avatar"
      <*> json <| "id"
      <*> json <| "name"
      <*> json <| "urls"
  }
}

extension Comment: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Comment> {
    let tmp = curry(Comment.init)
      <^> json <| "author"
      <*> json <| "body"
      <*> json <| "created_at"
    return tmp
      <*> (json <|? "deleted_at" >>- decodePositiveTimeInterval)
      <*> json <| "id"
  }
}

extension Comment: Equatable {
}
public func == (lhs: Comment, rhs: Comment) -> Bool {
  return lhs.id == rhs.id
}

// Decode a time interval so that non-positive values are coalesced to `nil`. We do this because the API
// sends back `0` when the comment hasn't been deleted, and we'd rather handle that value as `nil`.
private func decodePositiveTimeInterval(_ interval: TimeInterval?) -> Decoded<TimeInterval?> {
  if let interval = interval, interval > 0.0 {
    return .success(interval)
  }
  return .success(nil)
}
