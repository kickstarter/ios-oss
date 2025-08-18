// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PledgedProjectsOverviewPledgeFlags: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PledgedProjectsOverviewPledgeFlags
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PledgedProjectsOverviewPledgeFlags>>

  public struct MockFields {
    @Field<String>("icon") public var icon
    @Field<String>("message") public var message
    @Field<String>("type") public var type
  }
}

public extension Mock where O == PledgedProjectsOverviewPledgeFlags {
  convenience init(
    icon: String? = nil,
    message: String? = nil,
    type: String? = nil
  ) {
    self.init()
    _setScalar(icon, for: \.icon)
    _setScalar(message, for: \.message)
    _setScalar(type, for: \.type)
  }
}
