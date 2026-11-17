import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

class GraphAPI_UpdateUserAccountInput_UpdateUserAccountInputTests: XCTestCase {
  func testChangePassword_WithCurrentAndNewPassword_Success() {
    let input = ChangePasswordInput(
      currentPassword: "pass0",
      newPassword: "pass1",
      newPasswordConfirmation: "pass1"
    )

    let graphInput = GraphAPI.UpdateUserAccountInput.from(input)

    XCTAssertEqual(graphInput.currentPassword.unwrapped, input.currentPassword)
    XCTAssertEqual(graphInput.password.unwrapped, input.newPassword)
    XCTAssertEqual(graphInput.passwordConfirmation.unwrapped, input.newPasswordConfirmation)
  }

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
