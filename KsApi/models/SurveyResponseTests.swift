import Argo
@testable import KsApi
import XCTest

internal final class SurveyResponseTests: XCTestCase {
  func testJSONDecoding() {
    let decoded = SurveyResponse.decodeJSONDictionary([
      "id": 1,
      "urls": [
        "web": [
          "survey": "http://"
        ]
      ]
    ])

    XCTAssertNil(decoded.error)
    XCTAssertNotNil(decoded.value)
    XCTAssertEqual(1, decoded.value?.id)
  }
}
