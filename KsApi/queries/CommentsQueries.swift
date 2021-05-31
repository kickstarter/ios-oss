import Foundation
import Prelude

/**
 Constructs a query to fetch a list of top-level `Comment`s. Accepts an optional cursor to page in
 the comments after that cursor from oldest to most recent.

 - parameter slug: A `Project`'s slug to fetch comments for.
 - parameter first: An optional limit parameter, defaulted to `Query.defaultPaginationCount`.
 - parameter after: An optional cursor to fetch the comments after.

 - returns: A `NonEmptySet<Query>`.
 */
public func commentsQuery(
  withProjectSlug slug: String,
  first: Int = Query.defaultPaginationCount,
  after cursor: String? = nil
) -> NonEmptySet<Query> {
  let args = Set([cursor.flatMap(QueryArg<Never>.after), .first(first)].compact())

  return Query.project(
    slug: slug,
    .id +| [
      .slug,
      .comments(
        args,
        .edges(
          .node(
            GraphComment.baseQueryProperties.op(
              .replies([], Connection<Query.Comment>.totalCount +| []) +| []
            )
          ) +| []
        ) +| [
          .pageInfo(
            .endCursor +| [
              .hasNextPage
            ]
          ),
          .totalCount
        ]
      )
    ]
  ) +| []
}

/**
 Constructs a query to fetch a `Comment`'s replies. Accepts an optional cursor to page in the
 most replies before that cursor from most recent to oldest.

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
