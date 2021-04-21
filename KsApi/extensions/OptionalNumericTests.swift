import Foundation
@testable import KsApi
import XCTest

final class OptionalNumericTests: XCTestCase {
  func testInt_OrZero() {
    XCTAssertEqual(0, Int?.none.orZero)
    XCTAssertEqual(2, Int?.some(2))
  }

  func testFloat_OrZero() {
    XCTAssertEqual(0.0, Float?.none.orZero)
    XCTAssertEqual(123.45, Float?.some(123.45))
  }

  func testDouble_OrZero() {
    XCTAssertEqual(0.0, Double?.none.orZero)
    XCTAssertEqual(123.45, Double?.some(123.45))
  }
}
