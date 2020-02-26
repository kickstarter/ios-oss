@testable import KsApi
import XCTest

final class ProjectCreatorDetailsEnvelopeTests: XCTestCase {
  func testJSONParsing_WithCompleteData() {
    let dictionary: [String: Any] = [
      "project": [
        "creator": [
          "id": "VXNlci0xOTMxNzE1OTI4",
          "backingsCount": 152,
          "launchedProjects": [
            "totalCount": 6
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let value = try? JSONDecoder().decode(ProjectCreatorDetailsEnvelope.self, from: data)

    XCTAssertEqual(value?.id, "VXNlci0xOTMxNzE1OTI4")
    XCTAssertEqual(value?.backingsCount, 152)
    XCTAssertEqual(value?.launchedProjectsCount, 6)
  }

  func testJSONParsing_WithPartialData() {
    let dictionary: [String: Any] = [
      "project": [
        "creator": [
          "id": "VXNlci0xOTMxNzE1OTI4",
          "lastLogin": 1_581_718_873
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let value = try? JSONDecoder().decode(ProjectCreatorDetailsEnvelope.self, from: data)

    XCTAssertNil(value)
  }
}
