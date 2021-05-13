extension DeprecatedCommentsEnvelope {
  internal static let template = DeprecatedCommentsEnvelope(
    comments: [DeprecatedComment.template],
    urls: DeprecatedCommentsEnvelope.UrlsEnvelope(
      api: DeprecatedCommentsEnvelope.UrlsEnvelope.ApiEnvelope(
        moreComments: ""
      )
    )
  )
}
