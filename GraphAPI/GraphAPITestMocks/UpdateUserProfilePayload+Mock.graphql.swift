// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class UpdateUserProfilePayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.UpdateUserProfilePayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UpdateUserProfilePayload>>

  public struct MockFields {
    @Field<String>("clientMutationId") public var clientMutationId
  }
}

public extension Mock where O == UpdateUserProfilePayload {
  convenience init(
    clientMutationId: String? = nil
  ) {
    self.init()
    _setScalar(clientMutationId, for: \.clientMutationId)
  }
}
