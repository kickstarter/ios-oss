@testable import KsApi
import XCTest

final class CreateBackingEnvelope_CreateBackingMutation: XCTestCase {
  func test_SCA() {
    let backing = GraphAPI.CreateBackingMutation.Data.CreateBacking.Checkout.Backing(
      clientSecret: "client-secret",
      requiresAction: true
    )
    let checkout = GraphAPI.CreateBackingMutation.Data.CreateBacking.Checkout(
      backing: backing,
      id: "id",
      state: .authorizing
    )
    let data = GraphAPI.CreateBackingMutation.Data(
      createBacking: GraphAPI.CreateBackingMutation.Data.CreateBacking(checkout: checkout)
    )

    let env = CreateBackingEnvelope.from(data)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, "client-secret")
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, true)
    XCTAssertEqual(env?.createBacking.checkout.state, .authorizing)
  }

  func test_NonSCA_Successful() {
    let backing = GraphAPI.CreateBackingMutation.Data.CreateBacking.Checkout.Backing(
      clientSecret: nil,
      requiresAction: false
    )

    let checkout = GraphAPI.CreateBackingMutation.Data.CreateBacking.Checkout(
      backing: backing,
      id: "id",
      state: .successful
    )
    let data = GraphAPI.CreateBackingMutation.Data(
      createBacking: GraphAPI.CreateBackingMutation.Data.CreateBacking(checkout: checkout)
    )

    let env = CreateBackingEnvelope.from(data)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.createBacking.checkout.state, .successful)
  }

  func test_NonSCA_Failed() {
    let backing = GraphAPI.CreateBackingMutation.Data.CreateBacking.Checkout.Backing(
      clientSecret: nil,
      requiresAction: false
    )
    let checkout = GraphAPI.CreateBackingMutation.Data.CreateBacking.Checkout(
      backing: backing,
      id: "id",
      state: .failed
    )
    let data = GraphAPI.CreateBackingMutation.Data(
      createBacking: GraphAPI.CreateBackingMutation.Data.CreateBacking(checkout: checkout)
    )

    let env = CreateBackingEnvelope.from(data)

    XCTAssertEqual(env?.createBacking.checkout.id, "id")
    XCTAssertEqual(env?.createBacking.checkout.backing.clientSecret, nil)
    XCTAssertEqual(env?.createBacking.checkout.backing.requiresAction, false)
    XCTAssertEqual(env?.createBacking.checkout.state, .failed)
  }
}
