@testable import KsApi
import Prelude
import XCTest

final class ShippingRule_ManagePledgeViewTests: XCTestCase {
  func test() {
    let addOn1 = ManagePledgeViewBackingEnvelope.Backing.Reward.template
      |> \.shippingPreference .~ .restricted
    let addOn2 = ManagePledgeViewBackingEnvelope.Backing.Reward.template
      |> \.shippingPreference .~ .restricted

    let addOns = ManagePledgeViewBackingEnvelope.Backing.AddOns(nodes: [addOn1, addOn2])
    let backing = ManagePledgeViewBackingEnvelope.Backing.template
      |> \.shippingAmount .~ Money(amount: 30, currency: .cad, symbol: "$")
      |> \.reward .~ (
        .template
          |> \.shippingPreference .~ .restricted
      )
      |> \.addOns .~ addOns

    let shippingRule = ShippingRule.shippingRule(from: backing)

    XCTAssertEqual(
      shippingRule?.cost, 10,
      "Shipping cost is the total shippingAmount divided by the number of rewards that ship"
    )
    XCTAssertEqual(shippingRule?.id, nil)
    XCTAssertEqual(shippingRule?.location.country, "CA")
    XCTAssertEqual(shippingRule?.location.localizedName, "Canada")
    XCTAssertEqual(shippingRule?.location.displayableName, "Canada")
    XCTAssertEqual(shippingRule?.location.id, 23_424_775)
  }
}
