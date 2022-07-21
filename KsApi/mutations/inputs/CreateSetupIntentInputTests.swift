@testable import KsApi
import Prelude
import XCTest

final class CreateSetupIntentInputTests: XCTestCase {
  func testCreateSetupIntentInputDictionary() {
    let createSetupIntentInput = CreateSetupIntentInput(projectId: "UHJvamVjdC0yMzEyODc5ODc")

    let input = createSetupIntentInput.toInputDictionary()

    XCTAssertEqual(input["projectId"] as? String, "UHJvamVjdC0yMzEyODc5ODc")
  }
}
