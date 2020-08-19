@testable import KsApi
import XCTest

final class ManagePledgeViewQueriesTests: XCTestCase {
  func testManagePledgeViewProjectBackingQuery() {
    let query = Query.build(managePledgeViewProjectBackingQuery(withBackingId: "12345"))

    // swiftformat:disable wrap
    let expected = """
    { backing(id: "12345") { addOns { nodes { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } startsAt } } amount { amount currency symbol } backer { id imageUrl: imageUrl(blur: false, width: 1024) name uid } backerCompleted bonusAmount { amount currency symbol } cancelable creditCard: paymentSource { ... on CreditCard { expirationDate id lastFour paymentType state type } } id location { country countryName displayableName id name } pledgedOn project { actions { displayConvertAmount } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name uid } currency deadlineAt description fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url usdExchangeRate } reward { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } startsAt } sequence shippingAmount { amount currency symbol } status } }
    """
    // swiftformat:enable wrap

    XCTAssertEqual(query, expected)
  }
}
