@testable import KsApi
@testable import Library
import Prelude
import XCTest

class GraphSchemaTests: XCTestCase {
  func testDecodeBase64() {
    XCTAssertEqual(decodeBase64("RnJlZWZvcm1Qb3N0LTMxODA0NjE="), "FreeformPost-3180461")
  }

  func testEncodeToBase64() {
    XCTAssertEqual(encodeToBase64("FreeformPost-3180461"), "RnJlZWZvcm1Qb3N0LTMxODA0NjE=")
  }
}
