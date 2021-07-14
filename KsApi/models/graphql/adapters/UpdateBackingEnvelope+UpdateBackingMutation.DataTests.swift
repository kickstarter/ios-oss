@testable import KsApi
import XCTest

final class UpdateBackingEnvelope_UpdateBackingMutationTests: XCTestCase {
  func test_SCA() {
    let dict: [String: Any] = [
      "updateBacking": [
        "checkout": [
          "id": "id",
          "state": GraphAPI.CheckoutState.authorizing,
          "backing": [
            "clientSecret": "client-secret",
            "requiresAction": true
          ]
        ]
      ]
    ]

    let data = GraphAPI.UpdateBackingMutation.Data(unsafeResultMap: dict)

    let env = UpdateBackingEnvelope.from(data)

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, "client-secret")
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, true)
    XCTAssertEqual(env?.updateBacking.checkout.state, .authorizing)
  }

  func test_NonSCA_Successful() {
    let dict: [String: Any] = [
      "updateBacking": [
        "checkout": [
          "id": "id",
          "state": GraphAPI.CheckoutState.successful,
          "backing": [
            "clientSecret": nil,
            "requiresAction": false
          ]
        ]
      ]
    ]

    let data = GraphAPI.UpdateBackingMutation.Data(unsafeResultMap: dict)

    let env = UpdateBackingEnvelope.from(data)

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.updateBacking.checkout.state, .successful)
  }

  func test_NonSCA_Failed() {
    let dict: [String: Any] = [
      "updateBacking": [
        "checkout": [
          "id": "id",
          "state": GraphAPI.CheckoutState.failed,
          "backing": [
            "clientSecret": nil,
            "requiresAction": false
          ]
        ]
      ]
    ]

    let data = GraphAPI.UpdateBackingMutation.Data(unsafeResultMap: dict)

    let env = UpdateBackingEnvelope.from(data)

    XCTAssertEqual(env?.updateBacking.checkout.id, "id")
    XCTAssertEqual(env?.updateBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.updateBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.updateBacking.checkout.state, .failed)
  }
}
