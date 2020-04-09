@testable import KsApi
import XCTest

final class SignInWithAppleEnvelopeTests: XCTestCase {
  func testSignInWithEnvelopeEnvelopeDecoding() {
    let jsonString = """
    {
      "signInWithApple": {
        "apiAccessToken": "api_access_token",
        "user": {
          "id": "VXNlci0x"
        }
      }
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(SignInWithAppleEnvelope.self, from: data)
      XCTAssertEqual(envelope.signInWithApple.apiAccessToken, "api_access_token")
      XCTAssertEqual(envelope.signInWithApple.user.id, "VXNlci0x")
      XCTAssertEqual(envelope.signInWithApple.user.intID, 1)
    } catch {
      XCTFail("\(error)")
    }
  }
}
