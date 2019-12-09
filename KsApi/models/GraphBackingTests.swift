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
              "id": "UHJvamVjdC0yMDQ4MTExNDEw",
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

      XCTAssertEqual("UHJvamVjdC0yMDQ4MTExNDEw", project?.id)
      XCTAssertEqual("Cool project", project?.name)
      XCTAssertEqual("/cool-project", project?.slug)
    } catch {
      XCTFail("Failed to decode GraphBackingEnvelope")
    }
  }
}
