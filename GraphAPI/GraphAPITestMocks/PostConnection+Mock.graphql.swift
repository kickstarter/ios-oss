// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PostConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PostConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PostConnection>>

  public struct MockFields {
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == PostConnection {
  convenience init(
    totalCount: Int? = nil
  ) {
    self.init()
    _setScalar(totalCount, for: \.totalCount)
  }
}
