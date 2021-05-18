import Foundation
import ReactiveSwift

struct GraphCommentsEnvelope: Decodable {
  var comments: [GraphComment]
  var cursor: String
  var hasNextPage: Bool
  var totalCount: Int
  var slug: String
}

extension GraphCommentsEnvelope {
  private enum CodingKeys: CodingKey {
    case comments
    case edges
    case node
    case project
    case pageInfo
    case endCursor
    case hasNextPage
    case totalCount
    case slug
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    let projectContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .project)
    
    self.slug = try projectContainer.decode(String.self, forKey: .slug)
    
    let commentsContainer = try projectContainer
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

    self.cursor = try pageInfoContainer.decode(String.self, forKey: .endCursor)
    self.hasNextPage = try pageInfoContainer.decode(Bool.self, forKey: .hasNextPage)
    self.totalCount = try commentsContainer.decode(Int.self, forKey: .totalCount)
  }
}
