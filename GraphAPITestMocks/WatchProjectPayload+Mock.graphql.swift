// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class WatchProjectPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.WatchProjectPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<WatchProjectPayload>>

  public struct MockFields {
    @Field<String>("clientMutationId") public var clientMutationId
    @Field<Project>("project") public var project
  }
}

public extension Mock where O == WatchProjectPayload {
  convenience init(
    clientMutationId: String? = nil,
    project: Mock<Project>? = nil
  ) {
    self.init()
    _setScalar(clientMutationId, for: \.clientMutationId)
    _setEntity(project, for: \.project)
  }
}
