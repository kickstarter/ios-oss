@testable import KsApi
import XCTest

final class ClearUserUnseenActivityEnvelope_ClearUserUnseenActivityMutationTests: XCTestCase {
  func testClearUserUnseenActivity_Success() {
    guard let env = ClearUserUnseenActivityEnvelope.from(ClearUserUnseenActivityMutationTemplate.valid.data)
    else {
      XCTFail("ClearUserUnseenActivityEnvelope should exist.")

      return
    }

    XCTAssertEqual(env.activityIndicatorCount, 3)
    XCTAssertEqual(
      ClearUserUnseenActivityEnvelope
        .producer(from: ClearUserUnseenActivityMutationTemplate.valid.data).allValues().count,
      1
    )
  }

  func testClearUserUnseenActivity_Failure() {
    let env = ClearUserUnseenActivityEnvelope.from(ClearUserUnseenActivityMutationTemplate.errored.data)

    XCTAssertNil(env?.activityIndicatorCount)
  }
}
