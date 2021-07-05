import Foundation

extension CommentRepliesEnvelope {
  static let multipleReplyTemplate = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [.replyTemplate, .replyTemplate, .replyTemplate],
    totalCount: 3
  )

  static let singleReplyTemplate = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [.replyTemplate],
    totalCount: 1
  )
}
