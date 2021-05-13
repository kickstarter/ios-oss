import Foundation
import Prelude

public func comments(
  withProjectSlug slug: String,
  first: Int = Query.defaultPaginationCount,
  after cursor: String?
) -> NonEmptySet<Query> {
  let args = Set([cursor.flatMap(QueryArg<Never>.after), .first(first)].compact())

  return Query.project(
    slug: slug,
    .id +| [
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
