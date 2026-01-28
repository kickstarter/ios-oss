@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class CreatePaymentSourceSetupIntentClientSecret_ConstructorTests: TestCase {
  func testCreatePaymentSourceSetupIntentInput_Reusable() {
    let input = CreatePaymentSourceSetupIntentInput.input(fromIntentClientSecret: "xyz", reuseable: true)

    XCTAssertEqual(input.intentClientSecret, "xyz")
    XCTAssertEqual(input.reuseable, true)
  }
}
