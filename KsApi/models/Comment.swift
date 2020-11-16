import Foundation

public struct Comment {
  public let author: Author
  public let body: String
  public let createdAt: TimeInterval
  public let deletedAt: TimeInterval?
  public let id: Int
}

extension Comment: Decodable {
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
    self.id = try values.decode(Int.self, forKey: .id)

    // Decode a time interval so that non-positive values are coalesced to `nil`. We do this because the API
    // sends back `0` when the comment hasn't been deleted, and we'd rather handle that value as `nil`.
    let value = try values.decodeIfPresent(TimeInterval.self, forKey: .deletedAt) ?? 0
    self.deletedAt = value > 0 ? value : nil
  }
}

extension Comment: Equatable {}

public func == (lhs: Comment, rhs: Comment) -> Bool {
  return lhs.id == rhs.id
}
