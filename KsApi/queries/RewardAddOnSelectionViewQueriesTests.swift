@testable import KsApi
import XCTest

final class RewardAddOnSelectionViewQueriesTests: XCTestCase {
  func testRewardAddOnSelectionViewAddOnsQuery() {
    let query = Query.build(rewardAddOnSelectionViewAddOnsQuery(withProjectSlug: "project-slug"))

    // swiftformat:disable wrap
    let expected = """
    { project(slug: "project-slug") { actions { displayConvertAmount } addOns { nodes { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } startsAt } } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name } currency deadlineAt description fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url } }
    """
    // swiftformat:enable wrap

    XCTAssertEqual(query, expected)
  }
}
