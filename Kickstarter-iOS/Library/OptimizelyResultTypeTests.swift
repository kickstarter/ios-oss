import Optimizely
import XCTest

final class OptimizelyResultTypeTests: XCTestCase {
  func testIsSuccess_ReturnsTrue() {
    let result = OptimizelyResult.success(true)

    XCTAssertNil(result.hasError)
  }

  func testIsSuccess_ReturnsFalse() {
    let result = OptimizelyResult<Any>.failure(OptimizelyError.generic)
    //TODO: Remove this comment, it's just to trigger a CI build.
    XCTAssertEqual("Unknown reason", result.hasError?.localizedDescription)
  }
}
