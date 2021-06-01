import Foundation

extension CommentRepliesEnvelope {
  static let template = CommentRepliesEnvelope(
    comment: .template,
    cursor: "cursor",
    hasPreviousPage: false,
    replies: [.template, .template, .template],
    totalCount: 3
  )
}
