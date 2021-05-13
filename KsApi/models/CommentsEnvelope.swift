import Foundation

public struct CommentsEnvelope: Decodable {
  public var comments: [Comment]
  public var cursor: String?
  public var hasNextPage: Bool
  public var totalCount: Int
}
