@testable import KsApi
import XCTest

class GraphAPI_UpdateUserAccountInput_UpdateUserAccountInputTests: XCTestCase {
  func testCreatePassword_WithNewPassword_Success() {
    let input = CreatePasswordInput(
      password: "pass1",
      passwordConfirmation: "pass1"
    )

    let graphInput = GraphAPI.UpdateUserAccountInput.from(input)

    XCTAssertEqual(graphInput.password, input.password)
    XCTAssertEqual(graphInput.passwordConfirmation, input.passwordConfirmation)
  }

  func testChangePassword_WithCurrentAndNewPassword_Success() {
    let input = ChangePasswordInput(
      currentPassword: "pass0",
      newPassword: "pass1",
      newPasswordConfirmation: "pass1"
    )

    let graphInput = GraphAPI.UpdateUserAccountInput.from(input)

    XCTAssertEqual(graphInput.currentPassword, input.currentPassword)
    XCTAssertEqual(graphInput.password, input.newPassword)
    XCTAssertEqual(graphInput.passwordConfirmation, input.newPasswordConfirmation)
  }

  func testChangeEmail_WithNewEmailAndPassword_Success() {
    let input = ChangeEmailInput(
      email: "kickstarter@email.com",
      currentPassword: "pass1"
    )

    let graphInput = GraphAPI.UpdateUserAccountInput.from(input)

    XCTAssertEqual(graphInput.email, input.email)
    XCTAssertEqual(graphInput.currentPassword, input.currentPassword)
  }
}
