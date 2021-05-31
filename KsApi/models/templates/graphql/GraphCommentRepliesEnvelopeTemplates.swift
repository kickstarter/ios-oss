import Foundation

extension GraphCommentRepliesEnvelope {
  static let template = GraphCommentRepliesEnvelope(
    comment: .template,
    replies: [.template, .template, .template],
    cursor: "WzMwNDkwNDY0XQ==",
    hasPreviousPage: true,
    totalCount: 100
  )
}
