import ApolloAPI
@testable import KsApi
import Prelude
import XCTest

final class CommentsEnvelope_GraphCommentsEnvelopeTests: XCTestCase {
  func testProjectComments() {
    guard let envelope = CommentsEnvelope
      .commentsEnvelope(from: FetchProjectCommentsQueryTemplate.valid.data) else {
      XCTFail()
      return
    }

    XCTAssertEqual(envelope.comments.count, 6)
    XCTAssertEqual(envelope.hasNextPage, false)
    XCTAssertEqual(envelope.cursor, "WzMzNTc0MTMzXQ==")
    XCTAssertEqual(envelope.totalCount, 14)
    XCTAssertNil(envelope.updateID)
    XCTAssertEqual(envelope.slug, "jonhodgsonmaptiles2/a-state-rpg-second-edition")
  }

  func testProjectUpdateComments() {
    guard let envelope = CommentsEnvelope.commentsEnvelope(from: FetchUpdateCommentsQueryTemplate.valid.data)
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(envelope.comments.count, 3)
    XCTAssertEqual(envelope.hasNextPage, false)
    XCTAssertEqual(envelope.cursor, "WzMzNjQ4MTM0XQ==")
    XCTAssertEqual(envelope.totalCount, 4)
    XCTAssertEqual(envelope.updateID, "RnJlZWZvcm1Qb3N0LTMyNjQ5MDU=")
    XCTAssertNil(envelope.slug)
  }
}
