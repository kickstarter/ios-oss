import Foundation
import ReactiveSwift

struct PostCommentEnvelope: Decodable {
  let createComment: CreateComment

  struct CreateComment: Decodable {
    let comment: GraphComment
  }
}

extension PostCommentEnvelope {
  static func modelProducer(from envelope: PostCommentEnvelope)
    -> SignalProducer<Comment, ErrorEnvelope> {
    return SignalProducer(value: Comment.comment(from: envelope.createComment.comment))
  }
}
