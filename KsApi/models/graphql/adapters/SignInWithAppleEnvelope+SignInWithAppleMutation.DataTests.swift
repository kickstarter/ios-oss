@testable import KsApi
import XCTest

final class SignInWithAppleEnvelope_SignInWithAppleMutation_DataTests: XCTestCase {
  func testSignInWithAppleEnvelope_Data_Success() {
    let dict: [String: Any] = [
      "signInWithApple": [
        "apiAccessToken": "foobar",
        "user": [
          "uid": "deadbeef"
        ]
      ]
    ]

    let data = GraphAPI.SignInWithAppleMutation.Data(unsafeResultMap: dict)

    let env = SignInWithAppleEnvelope.from(data)

    XCTAssertEqual(env?.signInWithApple.apiAccessToken, "foobar")
    XCTAssertEqual(env?.signInWithApple.user.uid, "deadbeef")

    // TODO: See if a more robust test can be written after mock client is introduced.
    XCTAssertEqual(SignInWithAppleEnvelope.producer(from: data).allValues().count, 1)
  }

  func testSignInWithAppleEnvelope_Data_Failed() {
    let dict: [String: Any] = [
      "wrongKey": [
        "apiAccessToken": "foobar",
        "user": [
          "uid": "deadbeef"
        ]
      ]
    ]

    let data = GraphAPI.SignInWithAppleMutation.Data(unsafeResultMap: dict)

    let env = SignInWithAppleEnvelope.from(data)

    XCTAssertNil(env)
  }
}
