@testable import KsApi
import XCTest

final class CreateSetupIntentMutationTests: XCTestCase {
  func testSetupIntentMutationProperties() {
    let input = CreateSetupIntentInput(
      projectId: "UHJvamVjdC0yMzEyODc5ODc",
      context: .crowdfundingCheckout
    )
    let mutation = CreateSetupIntentMutation(input: input)

    XCTAssertEqual(mutation.input.projectId, "UHJvamVjdC0yMzEyODc5ODc")
    XCTAssertEqual(
      mutation.input.setupIntentContext,
      GraphAPI.StripeIntentContextTypes.crowdfundingCheckout
    )
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
