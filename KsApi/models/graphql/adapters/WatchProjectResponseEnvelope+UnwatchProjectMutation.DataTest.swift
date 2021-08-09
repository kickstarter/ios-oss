@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_UnwatchProjectMutationTests: XCTestCase {
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

    let data = GraphAPI.UnwatchProjectMutation.Data(unsafeResultMap: dict)

    let envelope = WatchProjectResponseEnvelope.from(data)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, true)

    // TODO: See if a more robust test can be written after mock client is introduced.
    XCTAssertEqual(WatchProjectResponseEnvelope.producer(from: data).allValues().count, 1)
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

    let data = GraphAPI.UnwatchProjectMutation.Data(unsafeResultMap: dict)

    XCTAssertNil(WatchProjectResponseEnvelope.from(data))
  }
}
