import Prelude

extension CommentsEnvelope {
  internal static let singleCommentTemplate = CommentsEnvelope(
    comments: [Comment.template],
    cursor: nil,
    hasNextPage: false,
    slug: "slug",
    totalCount: 1
  )

  internal static let multipleCommentTemplate = CommentsEnvelope(
    comments: [Comment.template, Comment.superbackerTemplate],
    cursor: nil,
    hasNextPage: false,
    slug: "slug",
    totalCount: 2
  )

  internal static let failedRemovedSuccessfulCommentsTemplate = CommentsEnvelope(
    comments: [
      Comment.failedTemplate,
      Comment.deletedTemplate,
      Comment.superbackerTemplate,
      Comment.backerTemplate
    ],
    cursor: nil,
    hasNextPage: false,
    slug: "slug",
    totalCount: 4
  )

  internal static let emptyCommentsTemplate = CommentsEnvelope(
    comments: [],
    cursor: nil,
    hasNextPage: false,
    slug: "slug",
    totalCount: 0
  )

  internal static let successFailedRetryingRetrySuccessCommentsTemplate = CommentsEnvelope(
    comments: [
      .failedTemplate |> \.status .~ .success,
      .failedTemplate,
      .retryingTemplate,
      .retrySuccessTemplate
    ],
    cursor: nil,
    hasNextPage: false,
    slug: "slug",
    totalCount: 4
  )
}
