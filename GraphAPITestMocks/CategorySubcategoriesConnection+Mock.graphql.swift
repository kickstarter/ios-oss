// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CategorySubcategoriesConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CategorySubcategoriesConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CategorySubcategoriesConnection>>

  public struct MockFields {
    @Field<[Category?]>("nodes") public var nodes
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == CategorySubcategoriesConnection {
  convenience init(
    nodes: [Mock<Category>?]? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
    _setScalar(totalCount, for: \.totalCount)
  }
}
