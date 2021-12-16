import Foundation
import ReactiveSwift

struct PostCommentEnvelope: Decodable {
  let createComment: CreateComment

  struct CreateComment: Decodable {
    let comment: GraphComment
  }
}

extension PostCommentEnvelope {
  /**
   Return a signal producer containing `Comment` or `ErrorEnvelope`
   */
  static func producer(from data: GraphAPI.PostCommentMutation
    .Data) -> SignalProducer<Comment, ErrorEnvelope> {
    guard let commentMutationRawData = data.createComment?.comment,
      let comment = Comment.from(commentMutationRawData) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: comment)
  }
}
