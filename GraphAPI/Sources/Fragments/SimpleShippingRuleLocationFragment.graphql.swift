// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SimpleShippingRuleLocationFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment SimpleShippingRuleLocationFragment on SimpleShippingRule { __typename locationId locationName country }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.SimpleShippingRule }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("locationId", GraphAPI.ID?.self),
    .field("locationName", String?.self),
    .field("country", String.self),
  ] }

  public var locationId: GraphAPI.ID? { __data["locationId"] }
  public var locationName: String? { __data["locationName"] }
  public var country: String { __data["country"] }

  public init(
    locationId: GraphAPI.ID? = nil,
    locationName: String? = nil,
    country: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.SimpleShippingRule.typename,
        "locationId": locationId,
        "locationName": locationName,
        "country": country,
      ],
      fulfilledFragments: [
        ObjectIdentifier(SimpleShippingRuleLocationFragment.self)
      ]
    ))
  }
}
