@testable import KsApi
import XCTest

final class SignInWithAppleEnvelope_SignInWithAppleMutation_DataTests: XCTestCase {
  func testSignInWithAppleEnvelope_Data_Success() {
    let envProducer = SignInWithAppleEnvelope.producer(from: SignInWithAppleMutationTemplate.valid.data)
    let env = MockGraphQLClient.shared.client.data(from: envProducer)

    XCTAssertEqual(env?.signInWithApple.apiAccessToken, "foobar")
    XCTAssertEqual(env?.signInWithApple.user.uid, "deadbeef")

    XCTAssertEqual(
      SignInWithAppleEnvelope.producer(from: SignInWithAppleMutationTemplate.valid.data)
        .allValues().count,
      1
    )
  }

  func testSignInWithAppleEnvelope_Data_Failed() {
    let errorProducer = SignInWithAppleEnvelope.producer(from: SignInWithAppleMutationTemplate.errored.data)
    let error = MockGraphQLClient.shared.client.error(from: errorProducer)

    XCTAssertNotNil(error?.ksrCode)
  }
}
