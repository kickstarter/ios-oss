extension CommentsEnvelope {
  internal static let template = CommentsEnvelope(
    comments: [DeprecatedComment.template],
    urls: CommentsEnvelope.UrlsEnvelope(
      api: CommentsEnvelope.UrlsEnvelope.ApiEnvelope(
        moreComments: ""
      )
    )
  )
}
