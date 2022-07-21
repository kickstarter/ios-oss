@testable import KsApi
import XCTest

final class CreateSetupIntentMutationTests: XCTestCase {
  func testSetupIntentMutationProperties() {
    let input = CreateSetupIntentInput(projectId: "UHJvamVjdC0yMzEyODc5ODc")
    let mutation = CreateSetupIntentMutation(input: input)

    XCTAssertEqual(mutation.input.projectId, "UHJvamVjdC0yMzEyODc5ODc")
    XCTAssertEqual(
      mutation.description,
      """
      mutation CreateSetupIntent($input: CreateSetupIntentInput!) {
        createSetupIntent(input: $input) {
          clientSecret
        }
      }
      """
    )
  }
}
