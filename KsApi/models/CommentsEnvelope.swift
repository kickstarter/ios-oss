import Foundation
import GraphAPI
import ReactiveSwift

public struct CommentsEnvelope: Decodable {
  public var comments: [Comment]
  public var cursor: String? = nil
  public var hasNextPage: Bool
  public var slug: String? = nil
  public var totalCount: Int
  public var updateID: String? = nil
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
