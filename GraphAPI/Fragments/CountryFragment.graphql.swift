// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CountryFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CountryFragment on Country { __typename code name }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Country }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("code", GraphQLEnum<GraphAPI.CountryCode>.self),
    .field("name", String.self),
  ] }

  /// ISO ALPHA-2 code.
  public var code: GraphQLEnum<GraphAPI.CountryCode> { __data["code"] }
  /// Country name.
  public var name: String { __data["name"] }

  public init(
    code: GraphQLEnum<GraphAPI.CountryCode>,
    name: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Country.typename,
        "code": code,
        "name": name,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CountryFragment.self)
      ]
    ))
  }
}
