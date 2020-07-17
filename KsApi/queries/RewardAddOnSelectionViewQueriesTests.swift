@testable import KsApi
import XCTest

final class RewardAddOnSelectionViewQueriesTests: XCTestCase {
  func testRewardAddOnSelectionViewAddOnsQuery() {
    let query = Query.build(rewardAddOnSelectionViewAddOnsQuery(withProjectSlug: "project-slug"))

    // swiftformat:disable wrap
    let expected = """
    { project(slug: "project-slug") { actions { displayConvertAmount } addOns { nodes { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { id location { id } } startsAt } } fxRate pid } }
    """
    // swiftformat:enable wrap

    XCTAssertEqual(query, expected)
  }
}
