@testable import KsApi
import XCTest

final class ProjectVideoTests: XCTestCase {
  func testJsonParsing_WithFullData() {
    let video: Project.Video = try! Project.Video.decodeJSONDictionary([
      "id": 1,
      "high": "kickstarter.com/video.mp4"
    ])

    XCTAssertEqual(video.id, 1)
    XCTAssertEqual(video.high, "kickstarter.com/video.mp4")
  }
}
