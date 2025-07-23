// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Country: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Country
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Country>>

  public struct MockFields {
    @Field<GraphQLEnum<GraphAPI.CountryCode>>("code") public var code
    @Field<String>("name") public var name
  }
}

public extension Mock where O == Country {
  convenience init(
    code: GraphQLEnum<GraphAPI.CountryCode>? = nil,
    name: String? = nil
  ) {
    self.init()
    _setScalar(code, for: \.code)
    _setScalar(name, for: \.name)
  }
}
