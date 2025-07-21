// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PledgeProjectsOverview: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PledgeProjectsOverview
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PledgeProjectsOverview>>

  public struct MockFields {
    @Field<PledgedProjectsOverviewPledgesConnection>("pledges") public var pledges
  }
}

public extension Mock where O == PledgeProjectsOverview {
  convenience init(
    pledges: Mock<PledgedProjectsOverviewPledgesConnection>? = nil
  ) {
    self.init()
    _setEntity(pledges, for: \.pledges)
  }
}
