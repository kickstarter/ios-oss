@testable import KsApi
import XCTest

final class ClearUserUnseenActivityEnvelope_ClearUserUnseenActivityMutationTests: XCTestCase {
  func testClearUserUnseenActivity_Success() {
    let resultMap: [String: Any?] = [
      "clearUserUnseenActivity": [
        "clientMutationId": nil,
        "activityIndicatorCount": 3
      ]
    ]

    let data = GraphAPI.ClearUserUnseenActivityMutation.Data(unsafeResultMap: resultMap)

    guard let env = ClearUserUnseenActivityEnvelope.from(data) else {
      XCTFail("ClearUserUnseenActivityEnvelope should exist.")

      return
    }

    XCTAssertEqual(env.activityIndicatorCount, 3)

    // TODO: See if a more robust test can be written after mock client is introduced.
    XCTAssertEqual(ClearUserUnseenActivityEnvelope.producer(from: data).allValues().count, 1)
  }

  func testClearUserUnseenActivity_Failure() {
    let data = GraphAPI.ClearUserUnseenActivityMutation.Data(unsafeResultMap: [:])
    let env = ClearUserUnseenActivityEnvelope.from(data)

    XCTAssertNil(env?.activityIndicatorCount)
  }
}
