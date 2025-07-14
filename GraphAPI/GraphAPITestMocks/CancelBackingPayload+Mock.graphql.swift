// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CancelBackingPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CancelBackingPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CancelBackingPayload>>

  public struct MockFields {
    @Field<String>("clientMutationId") public var clientMutationId
  }
}

public extension Mock where O == CancelBackingPayload {
  convenience init(
    clientMutationId: String? = nil
  ) {
    self.init()
    _setScalar(clientMutationId, for: \.clientMutationId)
  }
}
