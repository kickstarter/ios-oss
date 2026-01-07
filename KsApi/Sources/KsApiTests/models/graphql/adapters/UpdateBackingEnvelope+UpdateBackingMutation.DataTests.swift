import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class UpdateBackingEnvelope_UpdateBackingMutationTests: XCTestCase {
  func mockData(checkoutState: GraphAPI.CheckoutState, sca: Bool) -> GraphAPI.UpdateBackingMutation.Data {
    let mock = Mock<GraphAPITestMocks.Mutation>()

    mock.updateBacking = Mock<GraphAPITestMocks.UpdateBackingPayload>()
    mock.updateBacking?.checkout = Mock<GraphAPITestMocks.Checkout>()
    mock.updateBacking?.checkout?.id = "id"
    mock.updateBacking?.checkout?.state = .case(checkoutState)
    mock.updateBacking?.checkout?.backing = Mock<GraphAPITestMocks.Backing>()
    mock.updateBacking?.checkout?.backing?.clientSecret = sca ? "client-secret" : nil
    mock.updateBacking?.checkout?.backing?.requiresAction = sca

    return GraphAPI.UpdateBackingMutation.Data.from(mock)
  }

  func test_SCA() {
    let envProducer = UpdateBackingEnvelope
      .producer(from: self.mockData(checkoutState: .authorizing, sca: true))
    let env = MockGraphQLClient.shared.client.data(from: envProducer)

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, "client-secret")
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, true)
    XCTAssertEqual(env?.updateBacking.checkout.state, .authorizing)
  }

  func test_NonSCA_Successful() {
    let env = UpdateBackingEnvelope
      .from(self.mockData(checkoutState: .successful, sca: false))

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.updateBacking.checkout.state, .successful)
  }

  func test_NonSCA_Failed() {
    let env = UpdateBackingEnvelope
      .from(self.mockData(checkoutState: .failed, sca: false))

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.updateBacking.checkout.state, .failed)
  }

  func test_BadResponse_Error() {
    let erroredData: GraphAPI.UpdateBackingMutation.Data = try! testGraphObject(jsonString: "{}")
    let errorProducer = UpdateBackingEnvelope.producer(from: erroredData)
    let error = MockGraphQLClient.shared.client.error(from: errorProducer)

    XCTAssertNotNil(error?.ksrCode)
  }
}
