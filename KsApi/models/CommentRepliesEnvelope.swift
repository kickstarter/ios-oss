import Foundation
import ReactiveSwift

public struct CommentRepliesEnvelope: Decodable {
  public var comment: Comment
  public var replies: [Comment]
  public var cursor: String?
  public var hasPreviousPage: Bool
  public var totalCount: Int
}

extension CommentRepliesEnvelope {
  static func envelopeProducer(from envelope: GraphCommentRepliesEnvelope)
    -> SignalProducer<CommentRepliesEnvelope, ErrorEnvelope> {
    return SignalProducer(value: CommentRepliesEnvelope.commentRepliesEnvelope(from: envelope))
  }
}
