// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class LocationsConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.LocationsConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<LocationsConnection>>

  public struct MockFields {
    @Field<[Location?]>("nodes") public var nodes
  }
}

public extension Mock where O == LocationsConnection {
  convenience init(
    nodes: [Mock<Location>?]? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
  }
}
