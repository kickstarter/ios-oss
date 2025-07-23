// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PledgeProjectOverviewItem: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PledgeProjectOverviewItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PledgeProjectOverviewItem>>

  public struct MockFields {
    @Field<Backing>("backing") public var backing
    @Field<[PledgedProjectsOverviewPledgeFlags]>("flags") public var flags
    @Field<String>("tierType") public var tierType
    @Field<String>("webviewUrl") public var webviewUrl
  }
}

public extension Mock where O == PledgeProjectOverviewItem {
  convenience init(
    backing: Mock<Backing>? = nil,
    flags: [Mock<PledgedProjectsOverviewPledgeFlags>]? = nil,
    tierType: String? = nil,
    webviewUrl: String? = nil
  ) {
    self.init()
    _setEntity(backing, for: \.backing)
    _setList(flags, for: \.flags)
    _setScalar(tierType, for: \.tierType)
    _setScalar(webviewUrl, for: \.webviewUrl)
  }
}
