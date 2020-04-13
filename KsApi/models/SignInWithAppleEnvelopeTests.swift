@testable import KsApi
import XCTest

final class SignInWithAppleEnvelopeTests: XCTestCase {
  func testSignInWithEnvelopeEnvelopeDecoding() {
    let jsonString = """
    {
      "signInWithApple": {
        "apiAccessToken": "api_access_token",
        "user": {
          "uid": "1"
        }
      }
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(SignInWithAppleEnvelope.self, from: data)
      XCTAssertEqual(envelope.signInWithApple.apiAccessToken, "api_access_token")
      XCTAssertEqual(envelope.signInWithApple.user.uid, "1")
    } catch {
      XCTFail("\(error)")
    }
  }
}
