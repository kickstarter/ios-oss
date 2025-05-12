import Foundation
import ReactiveSwift

extension CommentRepliesEnvelope {
  /**
   Returns a minimal `CommentRepliesEnvelope` from a `FetchCommentRepliesQuery.Data`
   */
  static func commentRepliesEnvelope(
    from data: GraphAPI.FetchCommentRepliesQuery.Data
  ) -> CommentRepliesEnvelope? {
    guard let parentCommentFragment = data.comment?.fragments.commentWithRepliesFragment?.fragments
      .commentBaseFragment,
      let repliesData = data.comment?.fragments.commentWithRepliesFragment?.replies,
      let parentComment = Comment.comment(from: parentCommentFragment, replyCount: repliesData.totalCount)
    else {
      return nil
    }

    let replies = repliesData.edges?
      .compactMap { $0?.node?.fragments.commentFragment }
      .compactMap {
        Comment.comment(from: $0.fragments.commentBaseFragment, replyCount: $0.replies?.totalCount)
      } ?? []

    return CommentRepliesEnvelope(
      comment: parentComment,
      cursor: repliesData.pageInfo.startCursor,
      hasPreviousPage: repliesData.pageInfo.hasPreviousPage,
      replies: replies,
      totalCount: repliesData.totalCount
    )
  }

  static func envelopeProducer(
    from data: GraphAPI.FetchCommentRepliesQuery
      .Data
  ) -> SignalProducer<CommentRepliesEnvelope, ErrorEnvelope> {
    guard let envelope = CommentRepliesEnvelope.commentRepliesEnvelope(from: data) else { return .empty }

    return SignalProducer(value: envelope)
  }
}
