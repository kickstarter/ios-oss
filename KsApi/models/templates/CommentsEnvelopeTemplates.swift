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
}
