// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PPOUserSetupFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PPOUserSetupFragment on User { __typename ppoHasAction backingActionCount }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("ppoHasAction", Bool?.self),
    .field("backingActionCount", Int?.self),
  ] }

  /// Whether backer has any action in PPO
  public var ppoHasAction: Bool? { __data["ppoHasAction"] }
  /// Count of pledges with pending action
  public var backingActionCount: Int? { __data["backingActionCount"] }

  public init(
    ppoHasAction: Bool? = nil,
    backingActionCount: Int? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.User.typename,
        "ppoHasAction": ppoHasAction,
        "backingActionCount": backingActionCount,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PPOUserSetupFragment.self)
      ]
    ))
  }
}
