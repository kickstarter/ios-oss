// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class UserSavedProjectsConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.UserSavedProjectsConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UserSavedProjectsConnection>>

  public struct MockFields {
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == UserSavedProjectsConnection {
  convenience init(
    totalCount: Int? = nil
  ) {
    self.init()
    _setScalar(totalCount, for: \.totalCount)
  }
}
