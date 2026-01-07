@testable import Library
import XCTest

final class AttributionTrackingTests: TestCase {
  func testParametersString() {
    let ref = "test-tag"
    let url = "test-url"
    let refInfo = RefInfo(RefTag(code: ref), deeplinkUrl: url)

    let string = AttributionTracking.eventParametersString(refInfo: refInfo)
    let json = self.jsonDict(string!)

    XCTAssertEqual(json["session_ref_tag"], ref)
    XCTAssertEqual(json["context_page_url"], url)
  }

  func testParametersString_emptyRefInfo() {
    let refInfo = RefInfo(nil)

    let string = AttributionTracking.eventParametersString(refInfo: refInfo)
    let json = self.jsonDict(string!)

    XCTAssertEqual(json["context_page_url"], "")
    XCTAssertEqual(json.count, 1) // Json shouldn't contain any other fields.
  }

  // MARK: - Helpers

  private func jsonDict(_ jsonString: String) -> [String: String] {
    let data = jsonString.data(using: .utf8)
    return try! JSONDecoder().decode([String: String].self, from: data!)
  }
}
