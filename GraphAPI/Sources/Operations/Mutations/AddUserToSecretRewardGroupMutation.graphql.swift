// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AddUserToSecretRewardGroupMutation: GraphQLMutation {
  public static let operationName: String = "addUserToSecretRewardGroup"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation addUserToSecretRewardGroup($input: AddUserToSecretRewardGroupInput!) { addUserToSecretRewardGroup(input: $input) { __typename project { __typename id rewards { __typename nodes { __typename id name } } } } }"#
    ))

  public var input: AddUserToSecretRewardGroupInput

  public init(input: AddUserToSecretRewardGroupInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addUserToSecretRewardGroup", AddUserToSecretRewardGroup?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Adds a user to a secret reward user group
    public var addUserToSecretRewardGroup: AddUserToSecretRewardGroup? { __data["addUserToSecretRewardGroup"] }

    public init(
      addUserToSecretRewardGroup: AddUserToSecretRewardGroup? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "addUserToSecretRewardGroup": addUserToSecretRewardGroup._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(AddUserToSecretRewardGroupMutation.Data.self)
        ]
      ))
    }

    /// AddUserToSecretRewardGroup
    ///
    /// Parent Type: `AddUserToSecretRewardGroupPayload`
    public struct AddUserToSecretRewardGroup: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.AddUserToSecretRewardGroupPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("project", Project.self),
      ] }

      /// Project data
      public var project: Project { __data["project"] }

      public init(
        project: Project
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.AddUserToSecretRewardGroupPayload.typename,
            "project": project._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(AddUserToSecretRewardGroupMutation.Data.AddUserToSecretRewardGroup.self)
          ]
        ))
      }

      /// AddUserToSecretRewardGroup.Project
      ///
      /// Parent Type: `Project`
      public struct Project: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphAPI.ID.self),
          .field("rewards", Rewards?.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        /// Project rewards.
        public var rewards: Rewards? { __data["rewards"] }

        public init(
          id: GraphAPI.ID,
          rewards: Rewards? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Project.typename,
              "id": id,
              "rewards": rewards._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(AddUserToSecretRewardGroupMutation.Data.AddUserToSecretRewardGroup.Project.self)
            ]
          ))
        }

        /// AddUserToSecretRewardGroup.Project.Rewards
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
                ObjectIdentifier(AddUserToSecretRewardGroupMutation.Data.AddUserToSecretRewardGroup.Project.Rewards.self)
              ]
            ))
          }

          /// AddUserToSecretRewardGroup.Project.Rewards.Node
          ///
          /// Parent Type: `Reward`
          public struct Node: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", GraphAPI.ID.self),
              .field("name", String?.self),
            ] }

            public var id: GraphAPI.ID { __data["id"] }
            /// A reward title.
            public var name: String? { __data["name"] }

            public init(
              id: GraphAPI.ID,
              name: String? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Reward.typename,
                  "id": id,
                  "name": name,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(AddUserToSecretRewardGroupMutation.Data.AddUserToSecretRewardGroup.Project.Rewards.Node.self)
                ]
              ))
            }
          }
        }
      }
    }
  }
}
