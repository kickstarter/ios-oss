import Foundation
import ReactiveSwift

extension CommentRepliesEnvelope {
  /**
   Returns a minimal `CommentRepliesEnvelope` from a `FetchCommentRepliesQuery.Data`
   */
  static func commentRepliesEnvelope(
    from data: GraphAPI.FetchCommentRepliesQuery.Data
  ) -> CommentRepliesEnvelope? {
    guard let parentCommentFragment = data.comment?.fragments.commentWithRepliesFragment,
      let parentComment = Comment.comment(from: parentCommentFragment),
      let repliesData = parentCommentFragment.replies else {
      return nil
    }

    let replies = repliesData.edges?
      .compactMap { $0?.node?.fragments.commentFragment }
      .compactMap(Comment.comment(from:)) ?? []

    return CommentRepliesEnvelope(
      comment: parentComment,
      cursor: repliesData.pageInfo.startCursor,
      hasPreviousPage: repliesData.pageInfo.hasPreviousPage,
      replies: replies,
      totalCount: repliesData.totalCount
    )
  }

  static func envelopeProducer(from data: GraphAPI.FetchCommentRepliesQuery
    .Data) -> SignalProducer<CommentRepliesEnvelope, ErrorEnvelope> {
    guard let envelope = CommentRepliesEnvelope.commentRepliesEnvelope(from: data) else { return .empty }

    return SignalProducer(value: envelope)
  }
}
