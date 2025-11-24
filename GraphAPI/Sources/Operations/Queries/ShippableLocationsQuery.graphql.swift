// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ShippableLocationsQuery: GraphQLQuery {
  public static let operationName: String = "ShippableLocations"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ShippableLocations { shippingCountryLocations { __typename ...LocationFragment } }"#,
      fragments: [LocationFragment.self]
    ))

  public init() {}

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("shippingCountryLocations", [ShippingCountryLocation].self),
    ] }

    /// Country locations for shipping rewards
    public var shippingCountryLocations: [ShippingCountryLocation] { __data["shippingCountryLocations"] }

    public init(
      shippingCountryLocations: [ShippingCountryLocation]
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "shippingCountryLocations": shippingCountryLocations._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ShippableLocationsQuery.Data.self)
        ]
      ))
    }

    /// ShippingCountryLocation
    ///
    /// Parent Type: `Location`
    public struct ShippingCountryLocation: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Location }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(LocationFragment.self),
      ] }

      /// The country code.
      public var country: String { __data["country"] }
      /// The localized country name.
      public var countryName: String? { __data["countryName"] }
      /// The displayable name. It includes the state code for US cities. ex: 'Seattle, WA'
      public var displayableName: String { __data["displayableName"] }
      public var id: GraphAPI.ID { __data["id"] }
      /// The localized name
      public var name: String { __data["name"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var locationFragment: LocationFragment { _toFragment() }
      }

      public init(
        country: String,
        countryName: String? = nil,
        displayableName: String,
        id: GraphAPI.ID,
        name: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Location.typename,
            "country": country,
            "countryName": countryName,
            "displayableName": displayableName,
            "id": id,
            "name": name,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ShippableLocationsQuery.Data.ShippingCountryLocation.self),
            ObjectIdentifier(LocationFragment.self)
          ]
        ))
      }
    }
  }
}
