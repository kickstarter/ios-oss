// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class AttachedVideo: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.AttachedVideo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<AttachedVideo>>

  public struct MockFields {
    @Field<GraphAPI.ID>("id") public var id
  }
}

public extension Mock where O == AttachedVideo {
  convenience init(
    id: GraphAPI.ID? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
  }
}
