// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct LastWaveFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment LastWaveFragment on CheckoutWave { __typename id active }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CheckoutWave }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", GraphAPI.ID.self),
    .field("active", Bool.self),
  ] }

  public var id: GraphAPI.ID { __data["id"] }
  /// Whether the wave is currently active
  public var active: Bool { __data["active"] }

  public init(
    id: GraphAPI.ID,
    active: Bool
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.CheckoutWave.typename,
        "id": id,
        "active": active,
      ],
      fulfilledFragments: [
        ObjectIdentifier(LastWaveFragment.self)
      ]
    ))
  }
}
