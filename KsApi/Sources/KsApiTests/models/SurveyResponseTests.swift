@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

internal final class SurveyResponseTests: XCTestCase {
  func testJSONDecoding() {
    let decoded: SurveyResponse! = SurveyResponse.decodeJSONDictionary([
      "id": 1,
      "urls": [
        "web": [
          "survey": "http://"
        ]
      ]
    ])

    XCTAssertNotNil(decoded)
    XCTAssertEqual(1, decoded.id)
  }
}
