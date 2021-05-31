import Foundation

extension CommentRepliesEnvelope {
  /**
   Returns a minimal `CommentRepliesEnvelope` from a `GraphCommentRepliesEnvelope`
   */
  static func commentRepliesEnvelope(
    from graphCommentRepliesEnvelope: GraphCommentRepliesEnvelope
  ) -> CommentRepliesEnvelope {
    return CommentRepliesEnvelope(
      comment: Comment.comment(from: graphCommentRepliesEnvelope.comment),
      replies: graphCommentRepliesEnvelope.replies.map(Comment.comment(from:)),
      cursor: graphCommentRepliesEnvelope.cursor,
      hasPreviousPage: graphCommentRepliesEnvelope.hasPreviousPage,
      totalCount: graphCommentRepliesEnvelope.totalCount
    )
  }
}
