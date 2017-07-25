extension CommentsEnvelope {
  internal static let template = CommentsEnvelope(
    comments: [Comment.template],
    urls: CommentsEnvelope.UrlsEnvelope(
      api: CommentsEnvelope.UrlsEnvelope.ApiEnvelope(
        moreComments: ""
      )
    )
  )
}
