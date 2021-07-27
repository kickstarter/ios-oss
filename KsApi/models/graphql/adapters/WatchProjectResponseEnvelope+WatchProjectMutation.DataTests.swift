@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_WatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let dict: [String: Any] = [
      "watchProject": [
        "clientMutationId": nil,
        "project": [
          "id": "id",
          "isWatched": true
        ]
      ]
    ]

    let data = GraphAPI.WatchProjectMutation.Data(unsafeResultMap: dict)

    let envelope = WatchProjectResponseEnvelope.from(data)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, true)
  }

  func test_envelopeFrom_ReturnsNil() {
    let dict: [String: Any] = [
      "wrongKey": [
        "clientMutationId": nil,
        "project": [
          "id": "id",
          "isWatched": true
        ]
      ]
    ]

    let data = GraphAPI.WatchProjectMutation.Data(unsafeResultMap: dict)

    XCTAssertNil(WatchProjectResponseEnvelope.from(data))
  }
}
