@testable import KsApi
import XCTest

final class CommentsEnvelope_GraphCommentsEnvelopeTests: XCTestCase {
  func test() {
    let envelope = CommentsEnvelope.commentsEnvelope(from: .template)

    XCTAssertEqual(
      envelope.comments,
      [Comment.comment(from: .template), Comment.comment(from: .template), Comment.comment(from: .template)]
    )
    XCTAssertEqual(envelope.hasNextPage, true)
    XCTAssertEqual(envelope.cursor, "WzMwNDkwNDY0XQ==")
    XCTAssertEqual(envelope.totalCount, 100)
    XCTAssertEqual(envelope.slug, "jadelabo-j1-beautiful-powerful-and-smart-idex-3d-printer")
  }
}
