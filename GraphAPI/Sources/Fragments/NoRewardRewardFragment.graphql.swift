// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct NoRewardRewardFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment NoRewardRewardFragment on Project { __typename minPledge fxRate }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("minPledge", Int.self),
    .field("fxRate", Double.self),
  ] }

  /// The min pledge amount for a single reward tier.
  public var minPledge: Int { __data["minPledge"] }
  /// Exchange rate for the current user's currency
  public var fxRate: Double { __data["fxRate"] }

  public init(
    minPledge: Int,
    fxRate: Double
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "minPledge": minPledge,
        "fxRate": fxRate,
      ],
      fulfilledFragments: [
        ObjectIdentifier(NoRewardRewardFragment.self)
      ]
    ))
  }
}
