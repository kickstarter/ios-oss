// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RewardItemsFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RewardItemsFragment on Reward { __typename id project { __typename id } items { __typename edges { __typename quantity node { __typename id name } } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", GraphAPI.ID.self),
    .field("project", Project?.self),
    .field("items", Items?.self),
  ] }

  public var id: GraphAPI.ID { __data["id"] }
  /// The project
  public var project: Project? { __data["project"] }
  /// Items in the reward.
  public var items: Items? { __data["items"] }

  public init(
    id: GraphAPI.ID,
    project: Project? = nil,
    items: Items? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Reward.typename,
        "id": id,
        "project": project._fieldData,
        "items": items._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(RewardItemsFragment.self)
      ]
    ))
  }

  /// Project
  ///
  /// Parent Type: `Project`
  public struct Project: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GraphAPI.ID.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }

    public init(
      id: GraphAPI.ID
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Project.typename,
          "id": id,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardItemsFragment.Project.self)
        ]
      ))
    }
  }

  /// Items
  ///
  /// Parent Type: `RewardItemsConnection`
  public struct Items: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardItemsConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("edges", [Edge?]?.self),
    ] }

    /// A list of edges.
    public var edges: [Edge?]? { __data["edges"] }

    public init(
      edges: [Edge?]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RewardItemsConnection.typename,
          "edges": edges._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardItemsFragment.Items.self)
        ]
      ))
    }

    /// Items.Edge
    ///
    /// Parent Type: `RewardItemEdge`
    public struct Edge: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardItemEdge }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("quantity", Int.self),
        .field("node", Node?.self),
      ] }

      /// The quantity of an item associated with a reward
      public var quantity: Int { __data["quantity"] }
      /// The item at the end of the edge.
      public var node: Node? { __data["node"] }

      public init(
        quantity: Int,
        node: Node? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RewardItemEdge.typename,
            "quantity": quantity,
            "node": node._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RewardItemsFragment.Items.Edge.self)
          ]
        ))
      }

      /// Items.Edge.Node
      ///
      /// Parent Type: `RewardItem`
      public struct Node: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphAPI.ID.self),
          .field("name", String.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        /// An item name.
        public var name: String { __data["name"] }

        public init(
          id: GraphAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.RewardItem.typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(RewardItemsFragment.Items.Edge.Node.self)
            ]
          ))
        }
      }
    }
  }
}
