import Foundation

public struct GraphMutationPostCommentEnvelope: Decodable {
  public let body: String
  public let id: String

  enum CodingKeys: String, CodingKey {
    case body
    case comment
    case createComment
    case id
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let comment = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .createComment)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .comment)

    self.body = try comment.decode(String.self, forKey: .body)
    self.id = try comment.decode(String.self, forKey: .id)
  }

  init(body: String, id: String) {
    self.body = body
    self.id = id
  }
}
