import Optimizely
import XCTest

final class OptimizelyResultTypeTests: XCTestCase {
  func testIsSuccess_ReturnsTrue() {
    let result = OptimizelyResult.success(true)

    XCTAssertNil(result.hasError)
  }

  func testIsSuccess_ReturnsFalse() {
    let result = OptimizelyResult<Any>.failure(OptimizelyError.generic)

    XCTAssertEqual("Unknown reason", result.hasError?.localizedDescription)
  }
}
