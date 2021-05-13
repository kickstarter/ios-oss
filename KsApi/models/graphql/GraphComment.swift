import Foundation
import Prelude

struct GraphComment: Decodable {
  var author: GraphAuthor
  var body: String
  var id: String
  var replyCount: Int

  struct GraphAuthor: Decodable {
    var id: String
    var isCreator: Bool
    var name: String
  }
}

extension GraphComment {
  /// All properties required to instantiate a `Comment` via a `GraphComment`
  static var baseQueryProperties: NonEmptySet<Query.Comment> {
    return Query.Comment.id +| [
      .author(
        .id +| [
          .isCreator,
          .name
        ]
      ),
      .body,
      .replies(
        .totalCount +| []
      )
    ]
  }
}

extension GraphComment {
  private enum CodingKeys: String, CodingKey {
    case author
    case body
    case id
    case totalCount
    case replies
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try values.decode(String.self, forKey: .id)
    self.author = try values.decode(GraphComment.GraphAuthor.self, forKey: .author)
    self.body = try values.decode(String.self, forKey: .body)
    self.replyCount = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .replies)
      .decode(Int.self, forKey: .totalCount)
  }
}

extension GraphComment.GraphAuthor {
  private enum CodingKeys: String, CodingKey {
    case id
    case isCreator
    case name
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try values.decode(String.self, forKey: .id)
    self.isCreator = try values.decodeIfPresent(Bool.self, forKey: .isCreator) ?? false
    self.name = try values.decode(String.self, forKey: .name)
  }
}
