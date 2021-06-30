import Foundation
import Prelude

/**
 Constructs a query to fetch a `Comment`'s replies. Accepts an optional cursor to page in the
 replies before that cursor from most recent to oldest.

 - parameter id: A parent `Comment`'s ID to fetch replies for.
 - parameter last: An optional limit parameter, defaulted to `Query.defaultPaginationCount`.
 - parameter before: An optional cursor to fetch the most recent replies before.

 - returns: A `NonEmptySet<Query>`.
 */
public func commentRepliesQuery(
  withCommentId id: String,
  last: Int = Query.defaultPaginationCount,
  before cursor: String? = nil
) -> NonEmptySet<Query> {
  let args = Set([cursor.flatMap(QueryArg<Never>.before), .last(last)].compact())

  return Query.comment(
    id: id,
    GraphComment.baseQueryProperties.op(
      .replies(args, Connection<Query.Comment>.totalCount +| [
        .edges(
          .node(GraphComment.baseQueryProperties) +| []
        ),
        .pageInfo(
          .startCursor +| [
            .hasPreviousPage
          ]
        ),
        .totalCount
      ]) +| []
    )
  ) +| []
}
