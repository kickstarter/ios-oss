// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Category: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Category
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Category>>

  public struct MockFields {
    @Field<String>("analyticsName") public var analyticsName
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<Category>("parentCategory") public var parentCategory
    @Field<GraphAPI.ID>("parentId") public var parentId
    @Field<CategorySubcategoriesConnection>("subcategories") public var subcategories
    @Field<Int>("totalProjectCount") public var totalProjectCount
  }
}

public extension Mock where O == Category {
  convenience init(
    analyticsName: String? = nil,
    id: GraphAPI.ID? = nil,
    name: String? = nil,
    parentCategory: Mock<Category>? = nil,
    parentId: GraphAPI.ID? = nil,
    subcategories: Mock<CategorySubcategoriesConnection>? = nil,
    totalProjectCount: Int? = nil
  ) {
    self.init()
    _setScalar(analyticsName, for: \.analyticsName)
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
    _setEntity(parentCategory, for: \.parentCategory)
    _setScalar(parentId, for: \.parentId)
    _setEntity(subcategories, for: \.subcategories)
    _setScalar(totalProjectCount, for: \.totalProjectCount)
  }
}
