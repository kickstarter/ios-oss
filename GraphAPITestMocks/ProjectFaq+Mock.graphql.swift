// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ProjectFaq: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ProjectFaq
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ProjectFaq>>

  public struct MockFields {
    @Field<String>("answer") public var answer
    @Field<GraphAPI.DateTime>("createdAt") public var createdAt
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("question") public var question
  }
}

public extension Mock where O == ProjectFaq {
  convenience init(
    answer: String? = nil,
    createdAt: GraphAPI.DateTime? = nil,
    id: GraphAPI.ID? = nil,
    question: String? = nil
  ) {
    self.init()
    _setScalar(answer, for: \.answer)
    _setScalar(createdAt, for: \.createdAt)
    _setScalar(id, for: \.id)
    _setScalar(question, for: \.question)
  }
}
