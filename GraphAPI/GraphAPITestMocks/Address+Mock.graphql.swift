// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Address: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Address
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Address>>

  public struct MockFields {
    @Field<String>("addressLine1") public var addressLine1
    @Field<String>("addressLine2") public var addressLine2
    @Field<String>("city") public var city
    @Field<GraphQLEnum<GraphAPI.CountryCode>>("countryCode") public var countryCode
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("phoneNumber") public var phoneNumber
    @Field<String>("postalCode") public var postalCode
    @Field<String>("recipientName") public var recipientName
    @Field<String>("region") public var region
  }
}

public extension Mock where O == Address {
  convenience init(
    addressLine1: String? = nil,
    addressLine2: String? = nil,
    city: String? = nil,
    countryCode: GraphQLEnum<GraphAPI.CountryCode>? = nil,
    id: GraphAPI.ID? = nil,
    phoneNumber: String? = nil,
    postalCode: String? = nil,
    recipientName: String? = nil,
    region: String? = nil
  ) {
    self.init()
    _setScalar(addressLine1, for: \.addressLine1)
    _setScalar(addressLine2, for: \.addressLine2)
    _setScalar(city, for: \.city)
    _setScalar(countryCode, for: \.countryCode)
    _setScalar(id, for: \.id)
    _setScalar(phoneNumber, for: \.phoneNumber)
    _setScalar(postalCode, for: \.postalCode)
    _setScalar(recipientName, for: \.recipientName)
    _setScalar(region, for: \.region)
  }
}
