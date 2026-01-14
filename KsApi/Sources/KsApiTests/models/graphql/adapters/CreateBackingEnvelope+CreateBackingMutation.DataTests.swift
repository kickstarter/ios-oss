@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

// FIXME: SPM - This file isn't included in the old test target, and it fails to run.
/*
final class CreateBackingEnvelope_CreateBackingMutationTests: XCTestCase {
  func test_SCA() {
    let envProducer = CreateBackingEnvelope
      .producer(from: CreateBackingMutationTemplate.valid(checkoutState: .authorizing, sca: true).data)
    let env = MockGraphQLClient.shared.client.data(from: envProducer)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, "client-secret")
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, true)
    XCTAssertEqual(env?.createBacking.checkout.state, .authorizing)
  }

  func test_NonSCA_Successful() {
    let envProducer = CreateBackingEnvelope
      .producer(from: CreateBackingMutationTemplate.valid(checkoutState: .successful, sca: false).data)
    let env = MockGraphQLClient.shared.client.data(from: envProducer)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.createBacking.checkout.state, .successful)
  }

  func test_NonSCA_Failed() {
    let envProducer = CreateBackingEnvelope
      .producer(from: CreateBackingMutationTemplate.valid(checkoutState: .failed, sca: false).data)
    let env = MockGraphQLClient.shared.client.data(from: envProducer)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.createBacking.checkout.state, .failed)
  }

  func test_BadResponse_Error() {
    let errorProducer = CreateBackingEnvelope.producer(from: CreateBackingMutationTemplate.errored.data)
    let error = MockGraphQLClient.shared.client.error(from: errorProducer)

    XCTAssertNotNil(error)
  }
}
*/
