// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class UserCreatedProjectsConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.UserCreatedProjectsConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UserCreatedProjectsConnection>>

  public struct MockFields {
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == UserCreatedProjectsConnection {
  convenience init(
    totalCount: Int? = nil
  ) {
    self.init()
    _setScalar(totalCount, for: \.totalCount)
  }
}
