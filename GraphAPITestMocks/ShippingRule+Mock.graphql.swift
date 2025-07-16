// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ShippingRule: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ShippingRule
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ShippingRule>>

  public struct MockFields {
    @Field<Money>("cost") public var cost
    @Field<Money>("estimatedMax") public var estimatedMax
    @Field<Money>("estimatedMin") public var estimatedMin
    @Field<GraphAPI.ID>("id") public var id
    @Field<Location>("location") public var location
  }
}

public extension Mock where O == ShippingRule {
  convenience init(
    cost: Mock<Money>? = nil,
    estimatedMax: Mock<Money>? = nil,
    estimatedMin: Mock<Money>? = nil,
    id: GraphAPI.ID? = nil,
    location: Mock<Location>? = nil
  ) {
    self.init()
    _setEntity(cost, for: \.cost)
    _setEntity(estimatedMax, for: \.estimatedMax)
    _setEntity(estimatedMin, for: \.estimatedMin)
    _setScalar(id, for: \.id)
    _setEntity(location, for: \.location)
  }
}
