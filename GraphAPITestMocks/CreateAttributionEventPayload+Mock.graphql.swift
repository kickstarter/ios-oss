// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CreateAttributionEventPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CreateAttributionEventPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CreateAttributionEventPayload>>

  public struct MockFields {
    @Field<Bool>("successful") public var successful
  }
}

public extension Mock where O == CreateAttributionEventPayload {
  convenience init(
    successful: Bool? = nil
  ) {
    self.init()
    _setScalar(successful, for: \.successful)
  }
}
