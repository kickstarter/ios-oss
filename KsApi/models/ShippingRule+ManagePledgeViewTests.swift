@testable import KsApi
import XCTest

final class ShippingRule_ManagePledgeViewTests: XCTestCase {
  func test() {
    let backing = ManagePledgeViewBackingEnvelope.Backing.template

    let shippingRule = ShippingRule.shippingRule(from: backing)

    XCTAssertEqual(shippingRule?.cost, 20)
    XCTAssertEqual(shippingRule?.id, nil)
    XCTAssertEqual(shippingRule?.location.country, "CA")
    XCTAssertEqual(shippingRule?.location.localizedName, "Canada")
    XCTAssertEqual(shippingRule?.location.displayableName, "Canada")
    XCTAssertEqual(shippingRule?.location.id, 23_424_775)
  }
}
