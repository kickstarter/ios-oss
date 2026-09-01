// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ShippingForLocation: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ShippingForLocation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ShippingForLocation>>

  public struct MockFields {
    @Field<SimpleShippingRule>("shippingRule") public var shippingRule
  }
}

public extension Mock where O == ShippingForLocation {
  convenience init(
    shippingRule: Mock<SimpleShippingRule>? = nil
  ) {
    self.init()
    _setEntity(shippingRule, for: \.shippingRule)
  }
}
