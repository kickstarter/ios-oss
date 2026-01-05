// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class UpdateBackerCompletedPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.UpdateBackerCompletedPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UpdateBackerCompletedPayload>>

  public struct MockFields {
    @Field<Backing>("backing") public var backing
  }
}

public extension Mock where O == UpdateBackerCompletedPayload {
  convenience init(
    backing: Mock<Backing>? = nil
  ) {
    self.init()
    _setEntity(backing, for: \.backing)
  }
}
