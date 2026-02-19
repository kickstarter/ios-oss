import GraphAPI
import KsApiTestHelpers
import XCTest

final class APISnapshotExampleTests: XCTestCase {
  func test_searchSnapshot() {
    let query = GraphAPI.FetchProjectBySlugQuery(slug: "crossfit-think-tank-cooler")

    // This would actually fetch the data and save it to disk:
    // let data = query.snapshot("example_snapshot", record: true)

    // This is loading it from the saved example:
    let response = query.snapshot("example_snapshot")
    XCTAssertNotNil(response)
    XCTAssertEqual(response?.project?.name, "Crossfit Think Tank Cooler")
  }
}
