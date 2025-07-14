import Foundation
import GraphAPI
@testable import KsApi
import XCTest

final class ShippingRule_ShippingRuleFragmentTests: XCTestCase {
  func fixable_test() {
    let shippingRuleFragment: GraphAPI.ShippingRuleFragment = try! testGraphObject(
      data: [
        "cost": [
          "amount": "50",
          "currency": GraphAPI.CurrencyCode.usd,
          "symbol": "$"
        ],
        "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
        "location": [
          "country": "CA",
          "countryName": "Canada",
          "displayableName": "Canada",
          "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
          "name": "Canada"
        ],
        "estimatedMin": [
          "amount": "10.00",
          "currency": GraphAPI.CurrencyCode.usd
        ],
        "estimatedMax": [
          "amount": "20.00",
          "currency": GraphAPI.CurrencyCode.usd
        ]
      ]
    )

    XCTAssertNotNil(ShippingRule.shippingRule(from: shippingRuleFragment))
  }
}
