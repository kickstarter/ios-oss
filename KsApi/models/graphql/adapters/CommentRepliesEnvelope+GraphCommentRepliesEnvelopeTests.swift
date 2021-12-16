@testable import KsApi
import XCTest

final class CommentRepliesEnvelope_GraphCommentRepliesEnvelopeTests: XCTestCase {
  func testCommentReplies() {
    guard let envelope = CommentRepliesEnvelope
      .commentRepliesEnvelope(from: FetchCommentRepliesQueryTemplate.valid.data) else {
      XCTFail()
      return
    }

    guard let commentId = decompose(id: "VXNlci04MjkwODk1MDY=") else {
      XCTFail()

      return
    }

    XCTAssertEqual(envelope.comment.author.id, "\(commentId)")
    XCTAssertEqual(envelope.comment.author.name, "Spencer Hamann")
    XCTAssertEqual(
      envelope.comment.body,
      "Does the machine laser engrave on brass and copper? What’s max depth look like?"
    )
    XCTAssertFalse(envelope.comment.isDeleted)
    XCTAssertEqual(envelope.comment.id, "Q29tbWVudC0zNDc0MDc3NA==")
    XCTAssertNil(envelope.comment.parentId)
    XCTAssertEqual(envelope.replies[0].id, "Q29tbWVudC0zNDc0Mzc2Mg==")
    XCTAssertEqual(envelope.replies[0].parentId, "Q29tbWVudC0zNDc0MDc3NA==")
    XCTAssertEqual(envelope.cursor, "Mg==")
    XCTAssertTrue(envelope.hasPreviousPage)
    XCTAssertEqual(envelope.totalCount, 8)
  }
}
