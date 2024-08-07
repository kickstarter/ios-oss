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
      ),
      estimatedMin: GraphAPI.ShippingRuleFragment.EstimatedMin(
        amount: "10.00",
        currency: GraphAPI.CurrencyCode.usd
      ),
      estimatedMax: GraphAPI.ShippingRuleFragment.EstimatedMax(
        amount: "20.00",
        currency: GraphAPI.CurrencyCode.usd
      )
    )

    XCTAssertNotNil(ShippingRule.shippingRule(from: shippingRuleFragment))
  }
}
