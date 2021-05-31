@testable import KsApi
import XCTest

final class Comment_GraphCommentTests: XCTestCase {
  func testComment_WithGraphComment_ShouldConvert() {
    let comment = Comment.comment(from: .template)

    XCTAssertEqual(comment.id, GraphComment.expectedCommentId)
    XCTAssertEqual(
      comment.body,
      GraphComment.expectedCommentBody
    )
    XCTAssertEqual(comment.replyCount, GraphComment.expectedCommentReplyCount)
    XCTAssertEqual(comment.author.id, GraphComment.expectedAuthorId)
    XCTAssertEqual(comment.author.name, GraphComment.expectedAuthorName)
    XCTAssertFalse(comment.author.isCreator)
    XCTAssertEqual(comment.author.imageUrl, GraphComment.expectedAuthorImageUrl)
  }
}
