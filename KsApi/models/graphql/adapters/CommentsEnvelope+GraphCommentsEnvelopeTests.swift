import ApolloAPI
@testable import KsApi
import Prelude
import XCTest

final class CommentsEnvelope_GraphCommentsEnvelopeTests: XCTestCase {
  func testProjectComments() {
    // FIXME: Add templates for Apollo models and update these tests.
    return
    guard
      let project = try? FetchProjectCommentsQuery.Data(jsonObject: [:]),
      let envelope = CommentsEnvelope.commentsEnvelope(from: project) else {
      XCTFail()
      return
    }

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
    // FIXME: Add templates for Apollo models and update these tests.
    return
    guard
      let update = try? FetchUpdateCommentsQuery.Data(jsonObject: [:]),
      let env = CommentsEnvelope.commentsEnvelope(from: update) else {
      XCTFail()
      return
    }

    let envelope = env |> \.updateID .~ "GDgOaVFgU4ODDGdfS=="

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
