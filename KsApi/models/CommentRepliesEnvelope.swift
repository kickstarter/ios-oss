import Foundation
import ReactiveSwift

public struct CommentRepliesEnvelope: Decodable {
  public var comment: Comment
  public var cursor: String?
  public var hasPreviousPage: Bool
  public var replies: [Comment]
  public var totalCount: Int
}

extension CommentRepliesEnvelope {
  public static let paginationLimit = 7
}
