// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Location: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Location
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Location>>

  public struct MockFields {
    @Field<String>("country") public var country
    @Field<String>("countryName") public var countryName
    @Field<String>("displayableName") public var displayableName
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("name") public var name
  }
}

public extension Mock where O == Location {
  convenience init(
    country: String? = nil,
    countryName: String? = nil,
    displayableName: String? = nil,
    id: GraphAPI.ID? = nil,
    name: String? = nil
  ) {
    self.init()
    _setScalar(country, for: \.country)
    _setScalar(countryName, for: \.countryName)
    _setScalar(displayableName, for: \.displayableName)
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
  }
}
