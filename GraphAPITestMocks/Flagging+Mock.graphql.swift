// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Flagging: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Flagging
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Flagging>>

  public struct MockFields {
    @Field<GraphAPI.ID>("id") public var id
    @Field<GraphQLEnum<GraphAPI.FlaggingKind>>("kind") public var kind
  }
}

public extension Mock where O == Flagging {
  convenience init(
    id: GraphAPI.ID? = nil,
    kind: GraphQLEnum<GraphAPI.FlaggingKind>? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(kind, for: \.kind)
  }
}
