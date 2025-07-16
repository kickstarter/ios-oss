// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CreateOrUpdateBackingAddressPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CreateOrUpdateBackingAddressPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CreateOrUpdateBackingAddressPayload>>

  public struct MockFields {
    @Field<Bool>("success") public var success
  }
}

public extension Mock where O == CreateOrUpdateBackingAddressPayload {
  convenience init(
    success: Bool? = nil
  ) {
    self.init()
    _setScalar(success, for: \.success)
  }
}
