import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class SignInWithAppleEnvelope_SignInWithAppleMutation_DataTests: XCTestCase {
  func testSignInWithAppleEnvelope_Data_Success() {
    let mock = Mock<GraphAPITestMocks.Mutation>()
    mock.signInWithApple = Mock<GraphAPITestMocks.SignInWithApplePayload>()
    mock.signInWithApple?.apiAccessToken = "foobar"
    mock.signInWithApple?.user = Mock<GraphAPITestMocks.User>()
    mock.signInWithApple?.user?.uid = "deadbeef"

    let data = GraphAPI.SignInWithAppleMutation.Data.from(mock)

    let envProducer = SignInWithAppleEnvelope.producer(from: data)
    let env = MockGraphQLClient.shared.client.data(from: envProducer)

    XCTAssertEqual(env?.signInWithApple.apiAccessToken, "foobar")
    XCTAssertEqual(env?.signInWithApple.user.uid, "deadbeef")

    XCTAssertEqual(
      envProducer.allValues().count,
      1
    )
  }

  func testSignInWithAppleEnvelope_Data_Failed() {
    let erroredData: GraphAPI.SignInWithAppleMutation.Data = try! testGraphObject(jsonString: "{}")
    let errorProducer = SignInWithAppleEnvelope.producer(from: erroredData)
    let error = MockGraphQLClient.shared.client.error(from: errorProducer)

    XCTAssertNotNil(error?.ksrCode)
  }
}
