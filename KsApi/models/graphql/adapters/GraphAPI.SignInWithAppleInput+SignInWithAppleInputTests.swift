@testable import KsApi
import XCTest

class GraphAPI_SignInWithAppleInput_SignInWithAppleInputTests: XCTestCase {
  func testSignInWithAppleInput_Success() {
    let input = SignInWithAppleInput(
      appId: "appId",
      authCode: "12345",
      firstName: "Hari",
      lastName: "Singh"
    )

    let graphApiInput = GraphAPI.SignInWithAppleInput.from(input)

    XCTAssertEqual(graphApiInput.iosAppId, "appId")
    XCTAssertEqual(graphApiInput.authCode, "12345")
    XCTAssertEqual(graphApiInput.firstName, "Hari")
    XCTAssertEqual(graphApiInput.lastName, "Singh")
  }
}
