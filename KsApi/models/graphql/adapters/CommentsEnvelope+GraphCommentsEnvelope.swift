import Foundation

extension CommentsEnvelope {
  /**
   Returns a minimal `CommentsEnvelope` from a `GraphCommentsEnvelope`
   */
  static func commentsEnvelope(from graphCommentsEnvelope: GraphCommentsEnvelope) -> CommentsEnvelope {
    return CommentsEnvelope(
      comments: graphCommentsEnvelope.comments.map(Comment.comment(from:)),
      cursor: graphCommentsEnvelope.cursor,
      hasNextPage: graphCommentsEnvelope.hasNextPage,
      slug: graphCommentsEnvelope.slug,
      updateID: graphCommentsEnvelope.updateID,
      totalCount: graphCommentsEnvelope.totalCount
    )
  }
}
