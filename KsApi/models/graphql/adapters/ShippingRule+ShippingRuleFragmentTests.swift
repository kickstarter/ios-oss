import Foundation
@testable import KsApi
import XCTest

final class ShippingRule_ShippingRuleFragmentTests: XCTestCase {
  func test() {
    let shippingRuleFragment = GraphAPI.ShippingRuleFragment(
      cost: GraphAPI.ShippingRuleFragment.Cost(
        amount: "50",
        currency: .usd,
        symbol: "$"
      ),
      id: "TG9jYXRpb24tMjM0MjQ3NzU=",
      location: GraphAPI.ShippingRuleFragment.Location(
        country: "CA",
        countryName: "Canada",
        displayableName: "Canada",
        id: "TG9jYXRpb24tMjM0MjQ3NzU=",
        name: "Canada"
      )
    )

    XCTAssertNotNil(ShippingRule.shippingRule(from: shippingRuleFragment))
  }
}
