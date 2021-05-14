import Foundation

public struct GraphMutationPostCommentResponseEnvelope: Decodable {
  public var createComment: CreateComment

  public struct CreateComment: Decodable {
    public var comment: Comment
  }

  public struct Comment: Decodable {
    public var body: String
    public var id: String
  }
}
