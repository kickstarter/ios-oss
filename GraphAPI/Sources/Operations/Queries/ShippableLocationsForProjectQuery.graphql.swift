// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ShippableLocationsForProjectQuery: GraphQLQuery {
  public static let operationName: String = "ShippableLocationsForProject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ShippableLocationsForProject($id: Int!) { project(pid: $id) { __typename rewards { __typename nodes { __typename simpleShippingRulesExpanded { __typename ...SimpleShippingRuleLocationFragment } } } } }"#,
      fragments: [SimpleShippingRuleLocationFragment.self]
    ))

  public var id: Int

  public init(id: Int) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["pid": .variable("id")]),
    ] }

    /// Fetches a project given its slug or pid.
    public var project: Project? { __data["project"] }

    public init(
      project: Project? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "project": project._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ShippableLocationsForProjectQuery.Data.self)
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
        .field("rewards", Rewards?.self),
      ] }

      /// Project rewards.
      public var rewards: Rewards? { __data["rewards"] }

      public init(
        rewards: Rewards? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Project.typename,
            "rewards": rewards._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ShippableLocationsForProjectQuery.Data.Project.self)
          ]
        ))
      }

      /// Project.Rewards
      ///
      /// Parent Type: `ProjectRewardConnection`
      public struct Rewards: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectRewardConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        public init(
          nodes: [Node?]? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.ProjectRewardConnection.typename,
              "nodes": nodes._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(ShippableLocationsForProjectQuery.Data.Project.Rewards.self)
            ]
          ))
        }

        /// Project.Rewards.Node
        ///
        /// Parent Type: `Reward`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("simpleShippingRulesExpanded", [SimpleShippingRulesExpanded?].self),
          ] }

          /// Simple shipping rules expanded as a faster alternative to shippingRulesExpanded since connection type is slow
          public var simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?] { __data["simpleShippingRulesExpanded"] }

          public init(
            simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?]
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Reward.typename,
                "simpleShippingRulesExpanded": simpleShippingRulesExpanded._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(ShippableLocationsForProjectQuery.Data.Project.Rewards.Node.self)
              ]
            ))
          }

          /// Project.Rewards.Node.SimpleShippingRulesExpanded
          ///
          /// Parent Type: `SimpleShippingRule`
          public struct SimpleShippingRulesExpanded: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.SimpleShippingRule }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(SimpleShippingRuleLocationFragment.self),
            ] }

            public var locationId: GraphAPI.ID? { __data["locationId"] }
            public var locationName: String? { __data["locationName"] }
            public var country: String { __data["country"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var simpleShippingRuleLocationFragment: SimpleShippingRuleLocationFragment { _toFragment() }
            }

            public init(
              locationId: GraphAPI.ID? = nil,
              locationName: String? = nil,
              country: String
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.SimpleShippingRule.typename,
                  "locationId": locationId,
                  "locationName": locationName,
                  "country": country,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(ShippableLocationsForProjectQuery.Data.Project.Rewards.Node.SimpleShippingRulesExpanded.self),
                  ObjectIdentifier(SimpleShippingRuleLocationFragment.self)
                ]
              ))
            }
          }
        }
      }
    }
  }
}
