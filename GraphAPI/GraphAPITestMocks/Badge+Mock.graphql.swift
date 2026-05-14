// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Badge: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Badge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Badge>>

  public struct MockFields {
    @Field<String>("icon") public var icon
    @Field<String>("text") public var text
    @Field<GraphQLEnum<GraphAPI.BadgeTypeEnum>>("type") public var type
  }
}

public extension Mock where O == Badge {
  convenience init(
    icon: String? = nil,
    text: String? = nil,
    type: GraphQLEnum<GraphAPI.BadgeTypeEnum>? = nil
  ) {
    self.init()
    _setScalar(icon, for: \.icon)
    _setScalar(text, for: \.text)
    _setScalar(type, for: \.type)
  }
}
