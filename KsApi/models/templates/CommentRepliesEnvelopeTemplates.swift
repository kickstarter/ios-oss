import Foundation

extension CommentRepliesEnvelope {
  static let template = CommentRepliesEnvelope(
    comment: .template,
    replies: [.template, .template, .template],
    cursor: "cursor",
    hasPreviousPage: false,
    totalCount: 3
  )
}
