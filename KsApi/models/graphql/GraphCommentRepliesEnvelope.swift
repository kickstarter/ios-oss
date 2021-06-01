import Foundation
import ReactiveSwift

struct GraphCommentRepliesEnvelope: Decodable {
  var comment: GraphComment
  var cursor: String?
  var hasPreviousPage: Bool
  var replies: [GraphComment]
  var totalCount: Int
}

extension GraphCommentRepliesEnvelope {
  private enum CodingKeys: CodingKey {
    case comment
    case edges
    case hasPreviousPage
    case id
    case node
    case pageInfo
    case replies
    case startCursor
    case totalCount
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.comment = try values.decode(GraphComment.self, forKey: .comment)

    let commentContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .comment)

    let repliesContainer = try commentContainer
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .replies)

    var edges = try repliesContainer
      .nestedUnkeyedContainer(forKey: .edges)

    var replies: [GraphComment] = []

    while !edges.isAtEnd {
      let node = try edges.nestedContainer(keyedBy: CodingKeys.self)
      replies.append(try node.decode(GraphComment.self, forKey: .node))
    }

    self.replies = replies

    let pageInfoContainer = try repliesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .pageInfo)

    self.cursor = try pageInfoContainer.decodeIfPresent(String.self, forKey: .startCursor)
    self.hasPreviousPage = try pageInfoContainer.decode(Bool.self, forKey: .hasPreviousPage)
    self.totalCount = try repliesContainer.decode(Int.self, forKey: .totalCount)
  }
}
