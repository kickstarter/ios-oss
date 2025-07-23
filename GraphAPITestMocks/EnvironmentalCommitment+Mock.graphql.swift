// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class EnvironmentalCommitment: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.EnvironmentalCommitment
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<EnvironmentalCommitment>>

  public struct MockFields {
    @Field<GraphQLEnum<GraphAPI.EnvironmentalCommitmentCategory>>("commitmentCategory") public var commitmentCategory
    @Field<String>("description") public var description
    @Field<GraphAPI.ID>("id") public var id
  }
}

public extension Mock where O == EnvironmentalCommitment {
  convenience init(
    commitmentCategory: GraphQLEnum<GraphAPI.EnvironmentalCommitmentCategory>? = nil,
    description: String? = nil,
    id: GraphAPI.ID? = nil
  ) {
    self.init()
    _setScalar(commitmentCategory, for: \.commitmentCategory)
    _setScalar(description, for: \.description)
    _setScalar(id, for: \.id)
  }
}
