@testable import KsApi
import Prelude
import XCTest

final class PushEnvelopeTests: XCTestCase {
  func testDecode_CommentProject() {
    let decodedEnvelope: PushEnvelope = try! PushEnvelope.decodeJSONDictionary([
      "aps": [
        "alert": "Hi"
      ],
      "activity": [
        "category": "comment-project",
        "comment": "Q29ij3oij234",
        "id": 1,
        "project_id": 2
      ]
    ])

    XCTAssertNotNil(decodedEnvelope.activity)
    XCTAssertEqual(.commentProject, decodedEnvelope.activity?.category)
    XCTAssertEqual("Q29ij3oij234", decodedEnvelope.activity?.commentId)
    XCTAssertEqual(1, decodedEnvelope.activity?.id)
    XCTAssertEqual(2, decodedEnvelope.activity?.projectId)
  }

  func testDecode_CommentPost() {
    let decodedEnvelope: PushEnvelope = try! PushEnvelope.decodeJSONDictionary([
      "aps": [
        "alert": "Hi"
      ],
      "activity": [
        "category": "comment-post",
        "comment": "Q29ij3oij234",
        "reply": "Qn123!@",
        "id": 1,
        "project_id": 2
      ]
    ])

    XCTAssertNotNil(decodedEnvelope.activity)
    XCTAssertEqual(.commentPost, decodedEnvelope.activity?.category)
    XCTAssertEqual("Q29ij3oij234", decodedEnvelope.activity?.commentId)
    XCTAssertEqual("Qn123!@", decodedEnvelope.activity?.replyId)
    XCTAssertEqual(1, decodedEnvelope.activity?.id)
    XCTAssertEqual(2, decodedEnvelope.activity?.projectId)
  }

  func testDecode_Update_WithUpdateKey() {
    let decodedEnvelope: PushEnvelope = try! PushEnvelope.decodeJSONDictionary([
      "aps": [
        "alert": "Hi"
      ],
      "update": [
        "id": 1,
        "project_id": 2
      ]
    ])

    XCTAssertNotNil(decodedEnvelope.update)
    XCTAssertEqual(1, decodedEnvelope.update?.id)
    XCTAssertEqual(2, decodedEnvelope.update?.projectId)
  }

  func testDecode_Update_WithPostKey() {
    let decodedEnvelope: PushEnvelope = try! PushEnvelope.decodeJSONDictionary([
      "aps": [
        "alert": "Hi"
      ],
      "post": [
        "id": 1,
        "project_id": 2
      ]
    ])

    XCTAssertNotNil(decodedEnvelope.update)
    XCTAssertEqual(1, decodedEnvelope.update?.id)
    XCTAssertEqual(2, decodedEnvelope.update?.projectId)
  }
}
