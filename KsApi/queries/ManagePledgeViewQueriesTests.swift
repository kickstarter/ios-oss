@testable import KsApi
import XCTest

final class ManagePledgeViewQueriesTests: XCTestCase {
  func testManagePledgeViewProjectBackingQuery() {
    let query = Query.build(managePledgeViewProjectBackingQuery(withBackingId: "12345"))

    // swiftformat:disable wrap
    let expected = """
    { backing(id: "12345") { addOns { nodes { amount { amount currency symbol } backersCount description displayName estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit name remainingQuantity startsAt } } amount { amount currency symbol } backer { name uid } cancelable creditCard: paymentSource { ... on CreditCard { expirationDate id lastFour paymentType type } } errorReason id location { name } pledgedOn project { name pid state } reward { amount { amount currency symbol } backersCount description displayName estimatedDeliveryOn id isMaxPledge items { nodes { id name } } name } sequence status } }
    """
    // swiftformat:enable wrap

    XCTAssertEqual(query, expected)
  }
}
