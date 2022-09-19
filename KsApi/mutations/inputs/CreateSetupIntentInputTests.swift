@testable import KsApi
import Prelude
import XCTest

final class CreateSetupIntentInputTests: XCTestCase {
  func testCreateSetupIntentInputDictionary_WithValue_Success() {
    let createSetupIntentInput = CreateSetupIntentInput(projectId: "UHJvamVjdC0yMzEyODc5ODc")

    let input = createSetupIntentInput.toInputDictionary()

    XCTAssertEqual(input["projectId"] as? String, "UHJvamVjdC0yMzEyODc5ODc")
  }

  func testCreateSetupIntentInputDictionary_WithNoValue_Success() {
    let createSetupIntentInput = CreateSetupIntentInput(projectId: nil)

    let input = createSetupIntentInput.toInputDictionary()

    XCTAssertNil(input["projectId"] as? String)
  }
}
