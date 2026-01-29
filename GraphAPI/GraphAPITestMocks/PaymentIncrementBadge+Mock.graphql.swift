// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PaymentIncrementBadge: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PaymentIncrementBadge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PaymentIncrementBadge>>

  public struct MockFields {
    @Field<String>("copy") public var copy
    @Field<GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>>("variant") public var variant
  }
}

public extension Mock where O == PaymentIncrementBadge {
  convenience init(
    copy: String? = nil,
    variant: GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>? = nil
  ) {
    self.init()
    _setScalar(copy, for: \.copy)
    _setScalar(variant, for: \.variant)
  }
}
