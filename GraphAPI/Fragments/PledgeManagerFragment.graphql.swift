// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PledgeManagerFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PledgeManagerFragment on PledgeManager { __typename id acceptsNewBackers }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PledgeManager }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", GraphAPI.ID.self),
    .field("acceptsNewBackers", Bool.self),
  ] }

  public var id: GraphAPI.ID { __data["id"] }
  /// Whether the pledge manager accepts new backers or not
  public var acceptsNewBackers: Bool { __data["acceptsNewBackers"] }

  public init(
    id: GraphAPI.ID,
    acceptsNewBackers: Bool
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.PledgeManager.typename,
        "id": id,
        "acceptsNewBackers": acceptsNewBackers,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PledgeManagerFragment.self)
      ]
    ))
  }
}
