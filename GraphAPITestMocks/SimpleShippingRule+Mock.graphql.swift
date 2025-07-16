// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class SimpleShippingRule: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.SimpleShippingRule
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SimpleShippingRule>>

  public struct MockFields {
    @Field<String>("cost") public var cost
    @Field<String>("country") public var country
    @Field<String>("currency") public var currency
    @Field<String>("estimatedMax") public var estimatedMax
    @Field<String>("estimatedMin") public var estimatedMin
    @Field<GraphAPI.ID>("locationId") public var locationId
    @Field<String>("locationName") public var locationName
  }
}

public extension Mock where O == SimpleShippingRule {
  convenience init(
    cost: String? = nil,
    country: String? = nil,
    currency: String? = nil,
    estimatedMax: String? = nil,
    estimatedMin: String? = nil,
    locationId: GraphAPI.ID? = nil,
    locationName: String? = nil
  ) {
    self.init()
    _setScalar(cost, for: \.cost)
    _setScalar(country, for: \.country)
    _setScalar(currency, for: \.currency)
    _setScalar(estimatedMax, for: \.estimatedMax)
    _setScalar(estimatedMin, for: \.estimatedMin)
    _setScalar(locationId, for: \.locationId)
    _setScalar(locationName, for: \.locationName)
  }
}
