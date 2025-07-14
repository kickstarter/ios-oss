// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ClearUserUnseenActivityPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ClearUserUnseenActivityPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ClearUserUnseenActivityPayload>>

  public struct MockFields {
    @Field<Int>("activityIndicatorCount") public var activityIndicatorCount
    @Field<String>("clientMutationId") public var clientMutationId
  }
}

public extension Mock where O == ClearUserUnseenActivityPayload {
  convenience init(
    activityIndicatorCount: Int? = nil,
    clientMutationId: String? = nil
  ) {
    self.init()
    _setScalar(activityIndicatorCount, for: \.activityIndicatorCount)
    _setScalar(clientMutationId, for: \.clientMutationId)
  }
}
