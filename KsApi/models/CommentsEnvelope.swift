import Foundation
import ReactiveSwift

public struct CommentsEnvelope: Decodable {
  public var comments: [Comment]
  public var cursor: String?
  public var hasNextPage: Bool
  public var slug: String?
  public var totalCount: Int
  public var updateID: String?
}

extension CommentsEnvelope {
  static func envelopeProducer(from envelope: GraphCommentsEnvelope)
    -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    return SignalProducer(value: CommentsEnvelope.commentsEnvelope(from: envelope))
  }

  static func envelopeProducer(from data: FetchCommentsQuery.Data)
    -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    guard let envelope = CommentsEnvelope.commentsEnvelope(from: data) else { return .empty }
    return SignalProducer(value: envelope)
  }
}
