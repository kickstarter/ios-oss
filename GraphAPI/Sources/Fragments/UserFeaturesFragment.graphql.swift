// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct UserFeaturesFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment UserFeaturesFragment on User { __typename enabledFeatures }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("enabledFeatures", [GraphQLEnum<GraphAPI.Feature>].self),
  ] }

  /// The features enabled for the user; empty unless viewed by the user themself or an admin
  public var enabledFeatures: [GraphQLEnum<GraphAPI.Feature>] { __data["enabledFeatures"] }

  public init(
    enabledFeatures: [GraphQLEnum<GraphAPI.Feature>]
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.User.typename,
        "enabledFeatures": enabledFeatures,
      ],
      fulfilledFragments: [
        ObjectIdentifier(UserFeaturesFragment.self)
      ]
    ))
  }
}
