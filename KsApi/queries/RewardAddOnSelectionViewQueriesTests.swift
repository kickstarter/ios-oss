@testable import KsApi
import XCTest

final class RewardAddOnSelectionViewQueriesTests: XCTestCase {
  func testRewardAddOnSelectionViewAddOnsQuery() {
    let envelope = RewardAddOnSelectionViewEnvelope.template
    guard let graphId = envelope.project.addOns?.nodes.first?.shippingRulesExpanded?.nodes.first?.location.id
    else {
      XCTFail("ID for location should exist")
      return
    }
    let query = Query
      .build(rewardAddOnSelectionViewAddOnsQuery(withProjectSlug: "project-slug", andGraphId: graphId))

    // swiftformat:disable wrap
    let expected = """
    { project(slug: "project-slug") { actions { displayConvertAmount } addOns { nodes { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } shippingRulesExpanded(forLocation: "\(graphId)") { nodes { cost { amount currency symbol } id location { country countryName displayableName id name } } } startsAt } } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name uid } currency deadlineAt description fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url usdExchangeRate } }
    """
    // swiftformat:enable wrap

    XCTAssertEqual(query, expected)
  }

  func testRewardAddOnSelectionViewAddOnsQuery_NoGraphId() {
    let query = Query
      .build(rewardAddOnSelectionViewAddOnsQuery(withProjectSlug: "project-slug", andGraphId: nil))

    // swiftformat:disable wrap
    let expected = """
    { project(slug: "project-slug") { actions { displayConvertAmount } addOns { nodes { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } shippingRulesExpanded(forLocation: "") { nodes { cost { amount currency symbol } id location { country countryName displayableName id name } } } startsAt } } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name uid } currency deadlineAt description fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url usdExchangeRate } }
    """
    // swiftformat:enable wrap

    XCTAssertEqual(query, expected)
  }
}
