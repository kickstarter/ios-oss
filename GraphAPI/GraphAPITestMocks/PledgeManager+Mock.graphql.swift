// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PledgeManager: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PledgeManager
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PledgeManager>>

  public struct MockFields {
    @Field<Bool>("acceptsNewBackers") public var acceptsNewBackers
    @Field<GraphAPI.ID>("id") public var id
  }
}

public extension Mock where O == PledgeManager {
  convenience init(
    acceptsNewBackers: Bool? = nil,
    id: GraphAPI.ID? = nil
  ) {
    self.init()
    _setScalar(acceptsNewBackers, for: \.acceptsNewBackers)
    _setScalar(id, for: \.id)
  }
}
