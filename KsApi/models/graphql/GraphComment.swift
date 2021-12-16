import Foundation
import Prelude

struct GraphComment: Decodable {
  var author: GraphAuthor
  var authorBadges: [GraphBadge]
  var body: String
  var createdAt: TimeInterval
  var deleted: Bool
  var id: String
  var parentId: String?
  var replyCount: Int

  struct GraphAuthor: Decodable {
    var id: String
    var isCreator: Bool
    var name: String
    var imageUrl: String
  }

  enum GraphBadge: String, Decodable {
    case backer
    case creator
    case superbacker
    case collaborator
  }
}

extension GraphComment {
  private enum CodingKeys: String, CodingKey {
    case author
    case authorBadges
    case body
    case createdAt
    case deleted
    case id
    case parentId
    case totalCount
    case replies
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try values.decode(String.self, forKey: .id)
    self.author = try values.decode(GraphComment.GraphAuthor.self, forKey: .author)
    self.body = try values.decode(String.self, forKey: .body)
    self.replyCount = (try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .replies)
      .decode(Int.self, forKey: .totalCount)) ?? 0
    self.deleted = try values.decode(Bool.self, forKey: .deleted)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    self.authorBadges = try values.decode([GraphComment.GraphBadge].self, forKey: .authorBadges)
    self.parentId = try values.decodeIfPresent(String.self, forKey: .parentId)
  }
}

extension GraphComment.GraphAuthor {
  private enum CodingKeys: String, CodingKey {
    case id
    case isCreator
    case name
    case imageUrl
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let rawId = try values.decode(String.self, forKey: .id)
    let decomposedRawId = decompose(id: rawId) ?? -1

    self.id = decomposedRawId.description
    self.isCreator = try values.decodeIfPresent(Bool.self, forKey: .isCreator) ?? false
    self.name = try values.decode(String.self, forKey: .name)
    self.imageUrl = try values.decode(String.self, forKey: .imageUrl)
  }
}
