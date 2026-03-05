// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct SimpleShippingRulesExpandedFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment SimpleShippingRulesExpandedFragment on Reward { __typename simpleShippingRulesExpanded { __typename cost estimatedMin estimatedMax currency locationId locationName country } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("simpleShippingRulesExpanded", [SimpleShippingRulesExpanded?].self),
  ] }

  /// Simple shipping rules expanded as a faster alternative to shippingRulesExpanded since connection type is slow
  public var simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?] { __data["simpleShippingRulesExpanded"] }

  public init(
    simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?]
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Reward.typename,
        "simpleShippingRulesExpanded": simpleShippingRulesExpanded._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(SimpleShippingRulesExpandedFragment.self)
      ]
    ))
  }

  /// SimpleShippingRulesExpanded
  ///
  /// Parent Type: `SimpleShippingRule`
  public struct SimpleShippingRulesExpanded: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.SimpleShippingRule }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("cost", String?.self),
      .field("estimatedMin", String?.self),
      .field("estimatedMax", String?.self),
      .field("currency", String?.self),
      .field("locationId", GraphAPI.ID?.self),
      .field("locationName", String?.self),
      .field("country", String.self),
    ] }

    public var cost: String? { __data["cost"] }
    public var estimatedMin: String? { __data["estimatedMin"] }
    public var estimatedMax: String? { __data["estimatedMax"] }
    public var currency: String? { __data["currency"] }
    public var locationId: GraphAPI.ID? { __data["locationId"] }
    public var locationName: String? { __data["locationName"] }
    public var country: String { __data["country"] }

    public init(
      cost: String? = nil,
      estimatedMin: String? = nil,
      estimatedMax: String? = nil,
      currency: String? = nil,
      locationId: GraphAPI.ID? = nil,
      locationName: String? = nil,
      country: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.SimpleShippingRule.typename,
          "cost": cost,
          "estimatedMin": estimatedMin,
          "estimatedMax": estimatedMax,
          "currency": currency,
          "locationId": locationId,
          "locationName": locationName,
          "country": country,
        ],
        fulfilledFragments: [
          ObjectIdentifier(SimpleShippingRulesExpandedFragment.SimpleShippingRulesExpanded.self)
        ]
      ))
    }
  }
}
