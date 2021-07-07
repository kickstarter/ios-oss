import Foundation

extension CommentRepliesEnvelope {
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

  static let failedAndSuccessRepliesTemplate = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [.replyFailedTemplate, .replyTemplate],
    totalCount: 2
  )
}
