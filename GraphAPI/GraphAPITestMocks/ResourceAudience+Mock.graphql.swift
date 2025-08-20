// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ResourceAudience: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ResourceAudience
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ResourceAudience>>

  public struct MockFields {
    @Field<Bool>("secret") public var secret
  }
}

public extension Mock where O == ResourceAudience {
  convenience init(
    secret: Bool? = nil
  ) {
    self.init()
    _setScalar(secret, for: \.secret)
  }
}
