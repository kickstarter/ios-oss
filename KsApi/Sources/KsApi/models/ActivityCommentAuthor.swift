
import Foundation

public struct ActivityCommentAuthor: Decodable {
  public var avatar: Avatar
  public var id: Int
  public var name: String
  public var urls: Url

  public struct Avatar: Decodable {
    public var medium: String?
    public var small: String
    public var thumb: String
  }

  public struct Url {
    public var api: String
    public var web: String
  }
}

extension ActivityCommentAuthor.Url: Decodable {
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
