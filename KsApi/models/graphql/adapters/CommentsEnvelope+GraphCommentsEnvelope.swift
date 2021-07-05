import Foundation

extension CommentsEnvelope {
  /**
   Returns a minimal `CommentsEnvelope` from a `FetchProjectCommentsQuery.Data`
   */
  static func commentsEnvelope(from data: GraphAPI.FetchProjectCommentsQuery.Data) -> CommentsEnvelope? {
    guard let comments = data.project?.comments?.edges?
      .compactMap({ $0?.node?.fragments.commentFragment })
      .compactMap(Comment.comment(from:))
    else { return nil }

    return CommentsEnvelope(
      comments: comments,
      cursor: data.project?.comments?.pageInfo.endCursor,
      hasNextPage: data.project?.comments?.pageInfo.hasNextPage ?? false,
      slug: data.project?.slug,
      totalCount: data.project?.comments?.totalCount ?? 0,
      updateID: nil
    )
  }

  /**
   Returns a minimal `CommentsEnvelope` from a `FetchUpdateCommentsQuery.Data`
   */
  static func commentsEnvelope(from data: GraphAPI.FetchUpdateCommentsQuery.Data) -> CommentsEnvelope? {
    guard let comments = data.post?.asFreeformPost?.comments?.edges?
      .compactMap({ $0?.node?.fragments.commentFragment })
      .compactMap(Comment.comment(from:))
    else { return nil }

    return CommentsEnvelope(
      comments: comments,
      cursor: data.post?.asFreeformPost?.comments?.pageInfo.endCursor,
      hasNextPage: data.post?.asFreeformPost?.comments?.pageInfo.hasNextPage ?? false,
      slug: nil,
      totalCount: data.post?.asFreeformPost?.comments?.totalCount ?? 0,
      updateID: data.post?.asFreeformPost?.id
    )
  }
}
