// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CheckoutFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CheckoutFragment on Checkout { __typename backing { __typename clientSecret requiresAction } id state }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Checkout }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("backing", Backing.self),
    .field("id", GraphAPI.ID.self),
    .field("state", GraphQLEnum<GraphAPI.CheckoutState>.self),
  ] }

  /// The backing that the checkout is modifying.
  public var backing: Backing { __data["backing"] }
  public var id: GraphAPI.ID { __data["id"] }
  /// The current state of the checkout
  public var state: GraphQLEnum<GraphAPI.CheckoutState> { __data["state"] }

  public init(
    backing: Backing,
    id: GraphAPI.ID,
    state: GraphQLEnum<GraphAPI.CheckoutState>
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Checkout.typename,
        "backing": backing._fieldData,
        "id": id,
        "state": state,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CheckoutFragment.self)
      ]
    ))
  }

  /// Backing
  ///
  /// Parent Type: `Backing`
  public struct Backing: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("clientSecret", String?.self),
      .field("requiresAction", Bool?.self),
    ] }

    /// If `requires_action` is true, `client_secret` should be used to initiate additional client-side authentication steps
    public var clientSecret: String? { __data["clientSecret"] }
    /// Whether this checkout requires additional client-side authentication steps (e.g. 3DS2) to complete the on-session pledge flow
    public var requiresAction: Bool? { __data["requiresAction"] }

    public init(
      clientSecret: String? = nil,
      requiresAction: Bool? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Backing.typename,
          "clientSecret": clientSecret,
          "requiresAction": requiresAction,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CheckoutFragment.Backing.self)
        ]
      ))
    }
  }
}
