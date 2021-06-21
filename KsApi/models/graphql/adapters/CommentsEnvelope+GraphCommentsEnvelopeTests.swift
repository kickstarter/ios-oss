@testable import KsApi
import Prelude
import XCTest

final class CommentsEnvelope_GraphCommentsEnvelopeTests: XCTestCase {
  func testProjectComments() {
    let envelope = CommentsEnvelope.commentsEnvelope(from: .template)

    XCTAssertEqual(
      envelope.comments,
      [Comment.comment(from: .template), Comment.comment(from: .template), Comment.comment(from: .template)]
    )
    XCTAssertEqual(envelope.hasNextPage, true)
    XCTAssertEqual(envelope.cursor, "WzMwNDkwNDY0XQ==")
    XCTAssertEqual(envelope.totalCount, 100)
    XCTAssertNil(envelope.updateID)
    XCTAssertEqual(envelope.slug, "jadelabo-j1-beautiful-powerful-and-smart-idex-3d-printer")
  }

  func testProjectUpdateComments() {
    let envelope = CommentsEnvelope.commentsEnvelope(from: .projectUpdateTemplate)
      |> \.updateID .~ "GDgOaVFgU4ODDGdfS=="

    XCTAssertEqual(
      envelope.comments,
      [Comment.comment(from: .template), Comment.comment(from: .template), Comment.comment(from: .template)]
    )
    XCTAssertEqual(envelope.hasNextPage, true)
    XCTAssertEqual(envelope.cursor, "WzMwNDkwNDY0XQ==")
    XCTAssertEqual(envelope.totalCount, 100)
    XCTAssertEqual(envelope.updateID, "GDgOaVFgU4ODDGdfS==")
    XCTAssertNil(envelope.slug)
  }
}
