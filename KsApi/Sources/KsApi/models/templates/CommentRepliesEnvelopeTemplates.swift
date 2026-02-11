import Prelude

extension CommentRepliesEnvelope {
  static let failedAndSuccessRepliesTemplate = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [.replyFailedTemplate, .replyTemplate],
    totalCount: 2
  )

  static let singleReplyTemplate = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [
      .replyTemplate
    ],
    totalCount: 1
  )

  static let successfulRepliesTemplate = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [
      .replyTemplate,
      .replyTemplate,
      .replyTemplate,
      .replyTemplate,
      .replyTemplate,
      .replyTemplate,
      .replyTemplate
    ],
    totalCount: 14
  )

  static let successFailedRetryingRetrySuccessRepliesTemplate = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [
      .replyFailedTemplate,
      .replyTemplate,
      .replyTemplate |> \.status .~ .retrying,
      .replyTemplate |> \.status .~ .retrySuccess
    ],
    totalCount: 4
  )
}
