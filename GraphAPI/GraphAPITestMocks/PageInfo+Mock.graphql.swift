// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PageInfo: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PageInfo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PageInfo>>

  public struct MockFields {
    @Field<String>("endCursor") public var endCursor
    @Field<Bool>("hasNextPage") public var hasNextPage
    @Field<Bool>("hasPreviousPage") public var hasPreviousPage
    @Field<String>("startCursor") public var startCursor
  }
}

public extension Mock where O == PageInfo {
  convenience init(
    endCursor: String? = nil,
    hasNextPage: Bool? = nil,
    hasPreviousPage: Bool? = nil,
    startCursor: String? = nil
  ) {
    self.init()
    _setScalar(endCursor, for: \.endCursor)
    _setScalar(hasNextPage, for: \.hasNextPage)
    _setScalar(hasPreviousPage, for: \.hasPreviousPage)
    _setScalar(startCursor, for: \.startCursor)
  }
}
