@testable import KsApi
import XCTest

final class SignInWithAppleEnvelope_SignInWithAppleMutation_DataTests: XCTestCase {
  func testSignInWithAppleEnvelope_Data_Success() {
    let env = SignInWithAppleEnvelope.from(SignInWithAppleMutationTemplate.valid.data)

    XCTAssertEqual(env?.signInWithApple.apiAccessToken, "foobar")
    XCTAssertEqual(env?.signInWithApple.user.uid, "deadbeef")

    XCTAssertEqual(
      SignInWithAppleEnvelope.producer(from: SignInWithAppleMutationTemplate.valid.data)
        .allValues().count,
      1
    )
  }

  func testSignInWithAppleEnvelope_Data_Failed() {
    let env = SignInWithAppleEnvelope.from(SignInWithAppleMutationTemplate.errored.data)

    XCTAssertNil(env)
  }
}
