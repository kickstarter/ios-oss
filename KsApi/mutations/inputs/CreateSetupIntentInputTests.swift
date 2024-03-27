@testable import KsApi
import Prelude
import XCTest

final class CreateSetupIntentInputTests: XCTestCase {
  func testCreateSetupIntentInputDictionary_WithValue_Success() {
    let createSetupIntentInput = CreateSetupIntentInput(
      projectId: "UHJvamVjdC0yMzEyODc5ODc",
      context: .profileSettings
    )

    let input = createSetupIntentInput.toInputDictionary()

    XCTAssertEqual(input["projectId"] as? String, "UHJvamVjdC0yMzEyODc5ODc")
    XCTAssertEqual(input["setupIntentContext"] as? GraphAPI.StripeIntentContextTypes, .profileSettings)
  }

  func testCreateSetupIntentInputDictionary_WithNoValue_Success() {
    let createSetupIntentInput = CreateSetupIntentInput(projectId: nil, context: nil)

    let input = createSetupIntentInput.toInputDictionary()

    XCTAssertNil(input["projectId"] as? String)
    XCTAssertNil(input["setupIntentContext"] as? GraphAPI.StripeIntentContextTypes)
  }
}
