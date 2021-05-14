import Foundation

extension GraphMutationPostCommentResponseEnvelope {
  internal static let template =
    GraphMutationPostCommentResponseEnvelope(createComment: .init(comment: .init(
      body: "Hello World",
      id: "Q29tbWVudC0zMjY2MjU0MQ=="
    )))
}
