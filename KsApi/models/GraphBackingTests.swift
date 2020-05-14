@testable import KsApi
import XCTest

final class GraphBackingTests: XCTestCase {
  func testGraphBackingDecoding() {
    let jsonString = """
    {
      "backings": {
        "nodes": [
          {
            "errorReason": "no_reason",
            "status": "errored",
            "project": {
              "finalCollectionDate": "2020-04-08T15:15:05Z",
              "pid": 65,
              "name": "Cool project",
              "slug": "/cool-project"
            }
          }
        ]
      }
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(GraphBackingEnvelope.self, from: data)

      XCTAssertEqual(envelope.backings.nodes.count, 1)

      let backing = envelope.backings.nodes.first

      XCTAssertEqual("no_reason", backing?.errorReason)
      XCTAssertEqual(GraphBacking.Status.errored, backing?.status)

      let project = backing?.project

      XCTAssertEqual("2020-04-08T15:15:05Z", project?.finalCollectionDate)
      XCTAssertEqual(65, project?.pid)
      XCTAssertEqual("Cool project", project?.name)
      XCTAssertEqual("/cool-project", project?.slug)
    } catch {
      XCTFail("Failed to decode GraphBackingEnvelope")
    }
  }
}
