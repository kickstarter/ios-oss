// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class BlockUserPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.BlockUserPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<BlockUserPayload>>

  public struct MockFields {
    @Field<Bool>("success") public var success
  }
}

public extension Mock where O == BlockUserPayload {
  convenience init(
    success: Bool? = nil
  ) {
    self.init()
    _setScalar(success, for: \.success)
  }
}
