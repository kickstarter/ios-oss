// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Query: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<Backing>("backing") public var backing
    @Field<Checkout>("checkout") public var checkout
    @Field<Node>("comment") public var comment
    @Field<LocationsConnection>("locations") public var locations
    @Field<User>("me") public var me
    @Field<Node>("node") public var node
    @Field<PledgeProjectsOverview>("pledgeProjectsOverview") public var pledgeProjectsOverview
    @Field<Postable>("post") public var post
    @Field<Project>("project") public var project
    @Field<ProjectsConnectionWithTotalCount>("projects") public var projects
    @Field<[Category]>("rootCategories") public var rootCategories
  }
}

public extension Mock where O == Query {
  convenience init(
    backing: Mock<Backing>? = nil,
    checkout: Mock<Checkout>? = nil,
    comment: AnyMock? = nil,
    locations: Mock<LocationsConnection>? = nil,
    me: Mock<User>? = nil,
    node: AnyMock? = nil,
    pledgeProjectsOverview: Mock<PledgeProjectsOverview>? = nil,
    post: AnyMock? = nil,
    project: Mock<Project>? = nil,
    projects: Mock<ProjectsConnectionWithTotalCount>? = nil,
    rootCategories: [Mock<Category>]? = nil
  ) {
    self.init()
    _setEntity(backing, for: \.backing)
    _setEntity(checkout, for: \.checkout)
    _setEntity(comment, for: \.comment)
    _setEntity(locations, for: \.locations)
    _setEntity(me, for: \.me)
    _setEntity(node, for: \.node)
    _setEntity(pledgeProjectsOverview, for: \.pledgeProjectsOverview)
    _setEntity(post, for: \.post)
    _setEntity(project, for: \.project)
    _setEntity(projects, for: \.projects)
    _setList(rootCategories, for: \.rootCategories)
  }
}
