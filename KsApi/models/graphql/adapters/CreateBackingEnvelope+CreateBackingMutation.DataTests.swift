@testable import KsApi
import XCTest

final class CreateBackingEnvelope_CreateBackingMutationTests: XCTestCase {
  func test_SCA() {
    let dict: [String: Any] = [
      "createBacking": [
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

    let data = GraphAPI.CreateBackingMutation.Data(unsafeResultMap: dict)

    let env = CreateBackingEnvelope.from(data)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, "client-secret")
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, true)
    XCTAssertEqual(env?.createBacking.checkout.state, .authorizing)
  }

  func test_NonSCA_Successful() {
    let dict: [String: Any] = [
      "createBacking": [
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

    let data = GraphAPI.CreateBackingMutation.Data(unsafeResultMap: dict)

    let env = CreateBackingEnvelope.from(data)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.createBacking.checkout.state, .successful)
  }

  func test_NonSCA_Failed() {
    let dict: [String: Any] = [
      "createBacking": [
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

    let data = GraphAPI.CreateBackingMutation.Data(unsafeResultMap: dict)

    let env = CreateBackingEnvelope.from(data)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.createBacking.checkout.state, .failed)
  }
}
