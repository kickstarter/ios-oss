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
  static func envelopeProducer(from data: GraphAPI.FetchProjectCommentsQuery.Data)
    -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    guard let envelope = CommentsEnvelope.commentsEnvelope(from: data) else { return .empty }
    return SignalProducer(value: envelope)
  }

  static func envelopeProducer(from data: GraphAPI.FetchUpdateCommentsQuery.Data)
    -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    guard let envelope = CommentsEnvelope.commentsEnvelope(from: data) else { return .empty }
    return SignalProducer(value: envelope)
  }
}
