import ApolloTestSupport
import Foundation
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class ShippingRule_ShippingRuleFragmentTests: XCTestCase {
  func test() {
    let mock = Mock<GraphAPITestMocks.ShippingRule>()

    mock.cost = Mock<GraphAPITestMocks.Money>()
    mock.cost?.amount = "50"
    mock.cost?.currency = .case(GraphAPI.CurrencyCode.usd)
    mock.cost?.symbol = "$"

    mock.id = "TG9jYXRpb24tMjM0MjQ3NzU="

    mock.location = Mock<GraphAPITestMocks.Location>()
    mock.location?.country = "CA"
    mock.location?.countryName = "Canada"
    mock.location?.displayableName = "Canada"
    mock.location?.id = "TG9jYXRpb24tMjM0MjQ3NzU="
    mock.location?.name = "Canada"

    mock.estimatedMin = Mock<GraphAPITestMocks.Money>()
    mock.estimatedMin?.amount = "10.00"
    mock.estimatedMin?.currency = .case(GraphAPI.CurrencyCode.usd)

    mock.estimatedMax = Mock<GraphAPITestMocks.Money>()
    mock.estimatedMax?.amount = "20.00"
    mock.estimatedMax?.currency = .case(GraphAPI.CurrencyCode.usd)

    let shippingRuleFragment = GraphAPI.ShippingRuleFragment.from(mock)
    XCTAssertNotNil(ShippingRule.shippingRule(from: shippingRuleFragment))
  }
}
