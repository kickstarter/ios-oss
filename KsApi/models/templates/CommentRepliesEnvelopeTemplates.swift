import Foundation

extension CommentRepliesEnvelope {
  static let template = CommentRepliesEnvelope(
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
}
