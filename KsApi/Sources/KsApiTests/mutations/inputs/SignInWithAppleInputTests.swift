@testable import KsApi
import XCTest

final class SignInWithAppleInputTests: XCTestCase {
  func testInput() {
    let input = SignInWithAppleInput(
      appId: "app-123",
      authCode: "12345",
      firstName: "Blob",
      lastName: "Blobbo"
    )

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["iosAppId"] as? String, "app-123")
    XCTAssertEqual(inputDictionary["authCode"] as? String, "12345")
    XCTAssertEqual(inputDictionary["firstName"] as? String, "Blob")
    XCTAssertEqual(inputDictionary["lastName"] as? String, "Blobbo")
  }

  func testInput_FirstNameLastName_IsNil() {
    let input = SignInWithAppleInput(
      appId: "app-123",
      authCode: "12345",
      firstName: nil,
      lastName: nil
    )

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["iosAppId"] as? String, "app-123")
    XCTAssertEqual(inputDictionary["authCode"] as? String, "12345")
    XCTAssertNil(inputDictionary["firstName"] as? String)
    XCTAssertNil(inputDictionary["lastName"] as? String)
  }
}
