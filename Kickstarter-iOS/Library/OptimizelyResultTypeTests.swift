import Optimizely
import XCTest

final class OptimizelyResultTypeTests: XCTestCase {
  func testIsSuccess_ReturnsTrue() {
    let result = OptimizelyResult.success(true)

    XCTAssertTrue(result.isSuccess)
  }

  func testIsSuccess_ReturnsFalse() {
    let result = OptimizelyResult<Any>.failure(OptimizelyError.generic)

    XCTAssertFalse(result.isSuccess)
  }
}
