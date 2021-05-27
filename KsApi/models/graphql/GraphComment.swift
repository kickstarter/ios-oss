import Foundation
import Prelude

struct GraphComment: Decodable {
  var author: GraphAuthor
  var authorBadges: [GraphAuthor.GraphAuthorBadges]
  var body: String
  var id: String
  var replyCount: Int
  var deleted: Bool
  var createdAt: TimeInterval

  struct GraphAuthor: Decodable {
    var id: String
    var isCreator: Bool
    var name: String
    var imageUrl: String

    enum GraphAuthorBadges: String {
      case backer
      case creator
      case superbacker
    }
  }
}

extension GraphComment {
  /// All properties required to instantiate a `Comment` via a `GraphComment`
  static var baseQueryProperties: NonEmptySet<Query.Comment> {
    return Query.Comment.id +| [
      .author(
        .id +| [
          .isCreator,
          .name,
          .imageURL(width: Constants.previewImageWidth)
        ]
      ),
      .body,
      .createdAt,
      .deleted,
      .authorBadges,
      .replies(
        .totalCount +| []
      )
    ]
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
    self.deleted = try values.decode(Bool.self, forKey: .deleted)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)

    self.authorBadges = []

    let rawAuthorBadges = try values.decode([String].self, forKey: .authorBadges)

    rawAuthorBadges.forEach { badgeText in
      if let supportedBadge = GraphComment.GraphAuthor.GraphAuthorBadges(rawValue: badgeText) {
        self.authorBadges.append(supportedBadge)
      }
    }
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
