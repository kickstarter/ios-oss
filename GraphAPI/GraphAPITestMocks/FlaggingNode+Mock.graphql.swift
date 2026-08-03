// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class FlaggingNode: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.FlaggingNode
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<FlaggingNode>>

  public struct MockFields {
    @Field<String>("id") public var id
    @Field<GraphQLEnum<GraphAPI.NonDeprecatedFlaggingKind>>("kind") public var kind
    @Field<GraphQLEnum<GraphAPI.FlaggingNodeKind>>("nodeType") public var nodeType
    @Field<String>("parentId") public var parentId
    @Field<String>("placeholder") public var placeholder
    @Field<String>("subtitle") public var subtitle
    @Field<String>("title") public var title
  }
}

public extension Mock where O == FlaggingNode {
  convenience init(
    id: String? = nil,
    kind: GraphQLEnum<GraphAPI.NonDeprecatedFlaggingKind>? = nil,
    nodeType: GraphQLEnum<GraphAPI.FlaggingNodeKind>? = nil,
    parentId: String? = nil,
    placeholder: String? = nil,
    subtitle: String? = nil,
    title: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(kind, for: \.kind)
    _setScalar(nodeType, for: \.nodeType)
    _setScalar(parentId, for: \.parentId)
    _setScalar(placeholder, for: \.placeholder)
    _setScalar(subtitle, for: \.subtitle)
    _setScalar(title, for: \.title)
  }
}
