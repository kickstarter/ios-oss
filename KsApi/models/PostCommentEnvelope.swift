import Foundation

public struct PostCommentEnvelope: Decodable {
  public let createComment: CreateComment

  public struct CreateComment: Decodable {
    public let comment: Comment
  }
}

extension PostCommentEnvelope {
  public static let template = PostCommentEnvelope(createComment: CreateComment(comment: .template))
}
