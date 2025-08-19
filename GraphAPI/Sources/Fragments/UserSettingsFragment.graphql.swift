// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct UserSettingsFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment UserSettingsFragment on User { __typename chosenCurrency }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("chosenCurrency", String?.self),
  ] }

  /// The user's chosen currency
  public var chosenCurrency: String? { __data["chosenCurrency"] }

  public init(
    chosenCurrency: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.User.typename,
        "chosenCurrency": chosenCurrency,
      ],
      fulfilledFragments: [
        ObjectIdentifier(UserSettingsFragment.self)
      ]
    ))
  }
}
