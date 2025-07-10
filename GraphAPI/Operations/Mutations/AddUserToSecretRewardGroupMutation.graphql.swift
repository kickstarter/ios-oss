// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class AddUserToSecretRewardGroupMutation: GraphQLMutation {
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
            }
          }
        }
      }
    }
  }

}