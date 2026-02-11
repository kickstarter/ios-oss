import Foundation

public struct PostCommentInput: GraphMutationInput {
  let body: String

  /// This is base64 encoded ID of the Project-{projectId}}
  let commentableId: String

  /// If the comment is on the project level, this is nil. For replies, this is the ID of the comment.
  let parentId: String?

  public init(body: String, commentableId: String, parentId: String? = nil) {
    self.body = body
    self.commentableId = commentableId
    self.parentId = parentId
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "body": self.body,
      "commentableId": self.commentableId,
      "parentId": self.parentId as Any
    ]
  }
}
