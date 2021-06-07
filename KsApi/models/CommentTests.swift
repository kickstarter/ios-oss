@testable import KsApi
import XCTest

final class CommentTests: XCTestCase {
  func testOptimisticComment() {
    let comment = Comment.failableComment(
      withId: "comment-id",
      date: ApiMockDate().date,
      project: .template,
      user: .template,
      body: "Nice project!"
    )

    XCTAssertEqual("Nice project!", comment.body)
    XCTAssertEqual(false, comment.isDeleted)
    XCTAssertEqual(0, comment.replyCount)
    XCTAssertEqual("Blob", comment.author.name)
    XCTAssertEqual("http://www.kickstarter.com/medium.jpg", comment.author.imageUrl)
    XCTAssertEqual(.you, comment.authorBadge)
    XCTAssertEqual(.success, comment.status)
    XCTAssertEqual([.you], comment.authorBadges)
  }
}
