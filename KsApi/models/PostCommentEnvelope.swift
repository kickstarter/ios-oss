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
  static func producer(
    from data: GraphAPI.PostCommentMutation
      .Data
  ) -> SignalProducer<Comment, ErrorEnvelope> {
    guard let commentFragment = data.createComment?.comment?.fragments.commentFragment,
          let comment = Comment.comment(
            from: commentFragment.fragments.commentBaseFragment,
            replyCount: commentFragment.replies?.totalCount
          ) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: comment)
  }
}
