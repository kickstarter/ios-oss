// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CheckoutWave: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CheckoutWave
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CheckoutWave>>

  public struct MockFields {
    @Field<Bool>("active") public var active
    @Field<GraphAPI.ID>("id") public var id
  }
}

public extension Mock where O == CheckoutWave {
  convenience init(
    active: Bool? = nil,
    id: GraphAPI.ID? = nil
  ) {
    self.init()
    _setScalar(active, for: \.active)
    _setScalar(id, for: \.id)
  }
}
