@testable import KsApi
import Prelude
import XCTest

final class CreatePaymentSourceSetupIntentInputTests: XCTestCase {
  func testCreatePaymentSourceSetupIntentInputDictionary_WithValue_Success() {
    let createSetupIntentInput =
      CreatePaymentSourceSetupIntentInput(intentClientSecret: "UHJvamVjdC0yMzEyODc5ODc", reuseable: false)

    let input = createSetupIntentInput.toInputDictionary()

    XCTAssertEqual(input["intentClientSecret"] as? String, "UHJvamVjdC0yMzEyODc5ODc")
    XCTAssertEqual(input["reusable"] as? Bool, false)
  }
}
