import Foundation
import Prelude

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
          .node(GraphComment.baseQueryProperties) +| []
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
