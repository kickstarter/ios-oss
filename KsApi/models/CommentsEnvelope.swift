import Foundation
import ReactiveSwift

public struct CommentsEnvelope: Decodable {
  public var comments: [Comment]
  public var cursor: String?
  public var hasNextPage: Bool
  public var slug: String
  public var updateID: Int?
  public var totalCount: Int
}

extension CommentsEnvelope {
  static func envelopeProducer(from envelope: GraphCommentsEnvelope)
    -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    return SignalProducer(value: CommentsEnvelope.commentsEnvelope(from: envelope))
  }
}
