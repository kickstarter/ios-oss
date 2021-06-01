@testable import KsApi
import XCTest

final class CommentTests: XCTestCase {
  func testOptimisticComment() {
    let comment = Comment.optimisticComment(
      project: .template,
      user: .template,
      body: "Nice project!"
    )

    XCTAssertEqual("Nice project!", comment.body)
    XCTAssertEqual(false, comment.isDeleted)
    XCTAssertEqual(false, comment.isFailed)
    XCTAssertEqual(0, comment.replyCount)
    XCTAssertEqual("Blob", comment.author.name)
    XCTAssertEqual("http://www.kickstarter.com/medium.jpg", comment.author.imageUrl)
    XCTAssertEqual(Comment.AuthorBadge.you, comment.authorBadge)
  }
}
