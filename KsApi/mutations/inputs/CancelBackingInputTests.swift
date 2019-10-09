import Foundation
@testable import KsApi
import XCTest

final class CancelBackingInputTests: XCTestCase {
  func testCancelBacking_toInputDictionary_noNilValues() {
    let input = CancelBackingInput(backingId: "123", cancellationReason: "some reason")

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["id"] as? String, "123")
    XCTAssertEqual(inputDictionary["note"] as? String, "some reason")
  }

  func testCancelBacking_toInputDictionary_withNilValues() {
    let input = CancelBackingInput(backingId: "123", cancellationReason: nil)

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["id"] as? String, "123")
    XCTAssertNil(inputDictionary["note"])
  }
}
