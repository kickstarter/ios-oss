// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class UpdateUserAccountPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.UpdateUserAccountPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UpdateUserAccountPayload>>

  public struct MockFields {
    @Field<String>("clientMutationId") public var clientMutationId
  }
}

public extension Mock where O == UpdateUserAccountPayload {
  convenience init(
    clientMutationId: String? = nil
  ) {
    self.init()
    _setScalar(clientMutationId, for: \.clientMutationId)
  }
}
