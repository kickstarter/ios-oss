import GraphAPI
@testable import KsApi
import XCTest

final class ShippingRule_ShippingRulesExpandedFragmentTests: XCTestCase {
  func test_shippingRule_fromValidNode_noEstimates_isCorrect() {
    let node = GraphAPI.SimpleShippingRulesExpandedFragment.SimpleShippingRulesExpanded(
      cost: "3000.0",
      estimatedMin: nil,
      estimatedMax: nil,
      currency: "JPY",
      locationId: "TG9jYXRpb24tMjM0MjQ5NDU=",
      locationName: "Slowenien",
      country: "SI"
    )

    guard let rule = ShippingRule.shippingRule(from: node) else {
      XCTFail("Should have created shipping rule from node")
      return
    }

    XCTAssertEqual(rule.id, nil)
    XCTAssertEqual(rule.cost, 3_000.0)
    XCTAssertEqual(rule.location.graphID, "TG9jYXRpb24tMjM0MjQ5NDU=")
    XCTAssertEqual(rule.location.id, 23_424_945)
    XCTAssertEqual(rule.location.localizedName, "Slowenien")
    XCTAssertEqual(rule.location.country, "SI")
    XCTAssertNil(rule.estimatedMin)
    XCTAssertNil(rule.estimatedMax)
  }

  func test_shippingRule_fromValidNode_withEstimates_isCorrect() {
    let node = GraphAPI.SimpleShippingRulesExpandedFragment.SimpleShippingRulesExpanded(
      cost: "15.0",
      estimatedMin: "13",
      estimatedMax: "16",
      currency: "JPY",
      locationId: "TG9jYXRpb24tMjM0MjQ3NzU=",
      locationName: "Kanada",
      country: "CA"
    )

    guard let rule = ShippingRule.shippingRule(from: node) else {
      XCTFail("Should have created shipping rule from node")
      return
    }

    XCTAssertEqual(rule.id, nil)
    XCTAssertEqual(rule.cost, 15.0)
    XCTAssertEqual(rule.location.graphID, "TG9jYXRpb24tMjM0MjQ3NzU=")
    XCTAssertEqual(rule.location.id, 23_424_775)
    XCTAssertEqual(rule.location.localizedName, "Kanada")
    XCTAssertEqual(rule.location.country, "CA")
    XCTAssertEqual(rule.estimatedMin?.amount, 13.0)
    XCTAssertEqual(rule.estimatedMin?.currency, .jpy)
    XCTAssertNil(rule.estimatedMin?.symbol)
  }

  func test_shippingRule_fromInvalidFragmentNode_isNil() {
    let node = GraphAPI.SimpleShippingRulesExpandedFragment.SimpleShippingRulesExpanded(
      cost: "Hello, world",
      estimatedMin: "Not a number",
      estimatedMax: "Not a number",
      currency: "This isn't a currency code",
      locationId: "Not base 64",
      locationName: "Not a country",
      country: "Not a country code"
    )

    if ShippingRule.shippingRule(from: node) != nil {
      XCTFail("Should not created shipping rule from invalid node")
      return
    }
  }
}
