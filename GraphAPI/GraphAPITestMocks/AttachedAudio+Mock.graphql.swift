// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class AttachedAudio: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.AttachedAudio
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<AttachedAudio>>

  public struct MockFields {
    @Field<GraphAPI.ID>("id") public var id
  }
}

public extension Mock where O == AttachedAudio {
  convenience init(
    id: GraphAPI.ID? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
  }
}
