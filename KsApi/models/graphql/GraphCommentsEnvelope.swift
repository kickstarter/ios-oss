import Foundation
import ReactiveSwift

struct GraphCommentsEnvelope: Decodable {
  var comments: [GraphComment]
  var cursor: String?
  var hasNextPage: Bool
  var slug: String?
  var totalCount: Int
  var updateID: String?
}

extension GraphCommentsEnvelope {
  private enum CodingKeys: CodingKey {
    case comments
    case edges
    case id
    case node
    case post
    case project
    case pageInfo
    case endCursor
    case hasNextPage
    case slug
    case totalCount
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let container: KeyedDecodingContainer<GraphCommentsEnvelope.CodingKeys>

    if let projectContainer = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .project) {
      container = projectContainer
    } else {
      container = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .post)
      self.updateID = try container.decodeIfPresent(String.self, forKey: .id)
    }

    self.slug = try container.decodeIfPresent(String.self, forKey: .slug)

    let commentsContainer = try container
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .comments)

    var edges = try commentsContainer
      .nestedUnkeyedContainer(forKey: .edges)

    var comments: [GraphComment] = []

    while !edges.isAtEnd {
      let node = try edges.nestedContainer(keyedBy: CodingKeys.self)
      comments.append(try node.decode(GraphComment.self, forKey: .node))
    }

    self.comments = comments

    let pageInfoContainer = try commentsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .pageInfo)

    self.cursor = try pageInfoContainer.decodeIfPresent(String.self, forKey: .endCursor)
    self.hasNextPage = try pageInfoContainer.decode(Bool.self, forKey: .hasNextPage)
    self.totalCount = try commentsContainer.decode(Int.self, forKey: .totalCount)
  }
}
