@testable import KsApi
import XCTest

final class CommentRepliesEnvelope_GraphCommentRepliesEnvelopeTests: XCTestCase {
  func test() {
    let envelope = CommentRepliesEnvelope.commentRepliesEnvelope(from: .template)

    XCTAssertEqual(
      envelope.replies,
      [Comment.comment(from: .template), Comment.comment(from: .template), Comment.comment(from: .template)]
    )
    XCTAssertEqual(envelope.hasPreviousPage, true)
    XCTAssertEqual(envelope.cursor, "WzMwNDkwNDY0XQ==")
    XCTAssertEqual(envelope.totalCount, 100)
    XCTAssertEqual(envelope.comment, Comment.comment(from: .template))
  }
}
