@testable import KsApi
import XCTest

final class GraphBackingTests: XCTestCase {
  func testGraphBackingDecoding() {
    let jsonString = """
    {
      "backings": {
        "nodes": [{
          "id": "123412344",
          "errorReason": "Your card does not have sufficient funds available.",
          "project": {
            "finalCollectionDate": "2020-06-17T11:41:29-04:00",
            "name": "A summer dance festival",
            "pid": 674816336,
            "slug": "tequila/a-summer-dance-festival"
          },
          "status": "errored"
        }],
        "totalCount": 1
      },
      "id": "VXNlci00NzM1NjcxODQ="
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(GraphBackingEnvelope.self, from: data)

      XCTAssertEqual(envelope.backings.nodes.count, 1)

      let backing = envelope.backings.nodes.first

      XCTAssertEqual("123412344", backing?.id)
      XCTAssertEqual("Your card does not have sufficient funds available.", backing?.errorReason)
      XCTAssertEqual(GraphBacking.Status.errored, backing?.status)

      let project = backing?.project

      XCTAssertEqual("2020-06-17T11:41:29-04:00", project?.finalCollectionDate)
      XCTAssertEqual(674_816_336, project?.pid)
      XCTAssertEqual("A summer dance festival", project?.name)
      XCTAssertEqual("tequila/a-summer-dance-festival", project?.slug)
    } catch {
      XCTFail("Failed to decode GraphBackingEnvelope \(error)")
    }
  }
}
