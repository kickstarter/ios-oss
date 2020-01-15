import Foundation
import Library
import XCTest

final class DoubleTests: XCTestCase {
  func testAddingCurrency() {
    let amount = 10.0

    XCTAssertEqual(20.00, amount.addingCurrency(10.0))
    XCTAssertEqual(10.50, amount.addingCurrency(0.50))
  }

  func testMultiplyingCurrency() {
    let amount = 10.0

    XCTAssertEqual(20.00, amount.multiplyingCurrency(2.0))
    XCTAssertEqual(5.00, amount.multiplyingCurrency(0.5))
  }
}
