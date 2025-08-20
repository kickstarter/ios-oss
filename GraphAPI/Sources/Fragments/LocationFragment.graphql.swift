// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct LocationFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment LocationFragment on Location { __typename country countryName displayableName id name }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Location }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("country", String.self),
    .field("countryName", String?.self),
    .field("displayableName", String.self),
    .field("id", GraphAPI.ID.self),
    .field("name", String.self),
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
        ObjectIdentifier(LocationFragment.self)
      ]
    ))
  }
}
