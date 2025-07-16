// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class AddUserToSecretRewardGroupPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.AddUserToSecretRewardGroupPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<AddUserToSecretRewardGroupPayload>>

  public struct MockFields {
    @Field<Project>("project") public var project
  }
}

public extension Mock where O == AddUserToSecretRewardGroupPayload {
  convenience init(
    project: Mock<Project>? = nil
  ) {
    self.init()
    _setEntity(project, for: \.project)
  }
}
