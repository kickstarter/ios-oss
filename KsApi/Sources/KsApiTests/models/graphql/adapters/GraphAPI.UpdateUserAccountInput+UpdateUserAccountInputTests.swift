import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

class GraphAPI_UpdateUserAccountInput_UpdateUserAccountInputTests: XCTestCase {
  func testChangeEmail_WithNewEmailAndPassword_Success() {
    let input = ChangeEmailInput(
      email: "kickstarter@email.com",
      currentPassword: "pass1"
    )

    let graphInput = GraphAPI.UpdateUserAccountInput.from(input)

    XCTAssertEqual(graphInput.email.unwrapped, input.email)
    XCTAssertEqual(graphInput.currentPassword.unwrapped, input.currentPassword)
  }
}
