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
      totalCount: graphCommentsEnvelope.totalCount
    )
  }

  /**
   Returns a minimal `CommentsEnvelope` from a `FetchCommentsQuery.Data`
   */
  static func commentsEnvelope(from data: FetchCommentsQuery.Data) -> CommentsEnvelope? {
    // FIXME: Explore simpler way to access the node in edges structure.
    guard let comments = data.project?.comments?.edges?
      .compactMap({ $0?.node?.fragments.commentFragment })
      .compactMap(Comment.comment(from:))
    else { return nil }

    return CommentsEnvelope(
      comments: comments,
      cursor: data.project?.comments?.pageInfo.endCursor ?? "",
      hasNextPage: data.project?.comments?.pageInfo.hasNextPage ?? false,
      totalCount: data.project?.comments?.totalCount ?? 0
    )
  }
}
