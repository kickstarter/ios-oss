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
      cursor: graphCommentRepliesEnvelope.cursor,
      hasPreviousPage: graphCommentRepliesEnvelope.hasPreviousPage,
      replies: graphCommentRepliesEnvelope.replies.map(Comment.comment(from:)),
      totalCount: graphCommentRepliesEnvelope.totalCount
    )
  }
}
