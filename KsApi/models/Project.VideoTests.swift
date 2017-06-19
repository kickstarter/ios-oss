import XCTest
@testable import KsApi

final class ProjectVideoTests: XCTestCase {

  func testJsonParsing_WithFullData() {
    let video = Project.Video.decodeJSONDictionary([
      "id": 1,
      "high": "kickstarter.com/video.mp4"
    ])

    XCTAssertNil(video.error)
    XCTAssertEqual(video.value?.id, 1)
    XCTAssertEqual(video.value?.high, "kickstarter.com/video.mp4")
  }
}
