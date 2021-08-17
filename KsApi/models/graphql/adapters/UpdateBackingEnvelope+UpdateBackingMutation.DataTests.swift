@testable import KsApi
import XCTest

final class UpdateBackingEnvelope_UpdateBackingMutationTests: XCTestCase {
  func test_SCA() {
    let env = UpdateBackingEnvelope
      .from(UpdateBackingMutationTemplate.valid(checkoutState: .authorizing, sca: true).data)

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, "client-secret")
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, true)
    XCTAssertEqual(env?.updateBacking.checkout.state, .authorizing)
  }

  func test_NonSCA_Successful() {
    let env = UpdateBackingEnvelope
      .from(UpdateBackingMutationTemplate.valid(checkoutState: .successful, sca: false).data)

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.updateBacking.checkout.state, .successful)
  }

  func test_NonSCA_Failed() {
    let env = UpdateBackingEnvelope
      .from(UpdateBackingMutationTemplate.valid(checkoutState: .failed, sca: false).data)

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.updateBacking.checkout.state, .failed)
  }

  func test_BadResponse_Error() {
    let env = UpdateBackingEnvelope.from(UpdateBackingMutationTemplate.errored.data)

    XCTAssertNil(env)
  }
}
